/*
 * ==============================================================================
 * 
 * Created: 2017-4-11
 * Author: Jeremy
 * Company: LightPaw
 * 
 * ==============================================================================
 */

using System;
using System.Collections.Generic;
using FairyGUI;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.Audio;
using XLua;
using Object = UnityEngine.Object;

namespace LPCFramework {
    public class LoopAuidoItem {
        public float tick;
        public float lifetime;
        public bool hasDoFadeOut;
    }

    /// <summary>
    /// 音源状态
    /// </summary>
    public enum AudioState {
        NoInit = 0,
        Play = 1,
        Pause,
        UnPause,
        Stop,
        FadeIn,
        FadeOut
    }
    /// <summary>
    /// 混音音频组
    /// </summary>
    public enum GroupId {
        BG = 0,
        Battle,
        EAX,
    }

    [LuaCallCSharp]
    public class AudioManager : SingletonMonobehaviour<AudioManager>, IManager {

        public enum AudioCrossType {
            FadeIn = 0,
            FadeOut,
        }

        ///// <summary>
        ///// 背景音乐频道
        ///// </summary>
        //AudioPool mBgMusic;
        ///// <summary>
        ///// 战斗音乐频道
        ///// </summary>
        //AudioPool mBattleMusic;
        ///// <summary>
        ///// 引导音效频道
        ///// </summary>
        //AudioPool mGuildAudio;
        ///// <summary>
        ///// 其他音效频道
        ///// </summary>
        //AudioPool mOtherAudio;

        public float EAXAudioLifeTime = 120;

        public int EAXMaxPoolCount = 66;

        public float EAXPitch = 1; //音效

        // 全局音效音量
        private float m_globalAudioVolume = 1.0f;
        // 全局音乐音量
        private float m_globalMusicVolume = 1.0f;

        public float AudioBeginFadeOutMagicNum = 2.0f;

        public float GlobalMusicVolume {
            get { return m_globalAudioVolume; }
        }

        // 音源监听
        private AudioListener m_curAudioListener = null;
        // 音源监听
        private AudioListener m_defaultAudioListener = null;
        // 混音器
        private AudioMixer m_audioMixer = null;
        // 背景频道累加(目前俩，一个开启时，另一个关闭)
        private int m_bgMixerGroupId = 0;
        // 引导语频道累加(目前俩，一个开启时，另一个关闭)
        private int m_guildMixerGroupId = 0;

#if CHANNEL_WATER_HUNTER_LB
        // 路径前缀 ENG
        private string m_pathPrefix = "AudioEng/{0}";
#else
        // 路径前缀
        private string m_pathPrefix = "Audio/{0}.{1}";
#endif

        private Dictionary<GroupId, AudioPool> AudioPoolMap = new Dictionary<GroupId, AudioPool> ();
        private Dictionary<GroupId, string> GroupIdMap = new Dictionary<GroupId, string> ();

        public System.Action StupidLogicOver = null; // again and again logic, no use for game only for 

        LoopAuidoItem loopAuidoItem = null;

        public Dictionary<string, AudioAssetBundle> AudioAssetBundles = new Dictionary<string, AudioAssetBundle> ();

        public void OnInitialize () {
            GroupIdMap.Clear ();
            GroupIdMap.Add (GroupId.BG, "BG");
            GroupIdMap.Add (GroupId.Battle, "Battle");
            GroupIdMap.Add (GroupId.EAX, "EAX");

            if (m_defaultAudioListener == null) {
                GameObject listener = new GameObject ("AudioListener");
                listener.transform.parent = gameObject.transform;
                m_defaultAudioListener = listener.AddComponent<AudioListener> ();
                m_defaultAudioListener.enabled = false;
            }
            // 载入混音器
            Addressables.LoadAssetAsync<Object>("Audio/AudioMixer.mixer").Completed += (h) => {
                m_audioMixer = h.Result as AudioMixer;
            };

            SetAudioListener (null);
        }
        public void OnUpdate () {
            if (loopAuidoItem != null) {
                loopAuidoItem.tick += Time.unscaledDeltaTime;

                if (loopAuidoItem.tick >= (loopAuidoItem.lifetime - AudioBeginFadeOutMagicNum)) {
                    if (loopAuidoItem.hasDoFadeOut == false) {
                        loopAuidoItem.hasDoFadeOut = true;
                        SetGroupState (GroupId.BG, AudioState.Stop);
                    }
                }

                if (loopAuidoItem.tick >= loopAuidoItem.lifetime) {
                    loopAuidoItem = null;

                    if (StupidLogicOver != null) {

                        StupidLogicOver ();
                    }
                }
            }

            if (AudioPoolMap.ContainsKey (GroupId.EAX) && AudioPoolMap[GroupId.EAX] != null) {
                for (int i = AudioPoolMap[GroupId.EAX].Pool.Count - 1; i >= 0; i--) {
                    var asource = AudioPoolMap[GroupId.EAX].Pool[i];
                    asource.lifeTime -= Time.deltaTime;
                    //Debug.LogError(" name is : " + asource.audiosource.clip.name + " life time is :" + asource.lifeTime);
                    if (asource.audiosource.isPlaying == false && asource.lifeTime <= 0) {
                        Object.Destroy (asource.audiosource);
                        asource.audiosource = null;
                        AudioPoolMap[GroupId.EAX].Pool.RemoveAt (i);
                    }
                }
            }

        }
        public static void Destruct()
        {
            if (_S != null)
            {
                _S.OnDestruct();
            }
        }

        public void OnDestruct()
        {
            this.StupidLogicOver = null;
        }

        [LuaCallCSharp]
        /// <summary>
        /// 设置音源监听对象
        /// </summary>
        public void SetAudioListener (GameObject target) {
            if (null != m_curAudioListener) {
                m_curAudioListener.enabled = false;
            }
            AudioListener listener = null;
            if (null == target) {
                listener = m_defaultAudioListener;
            } else {
                listener = target.GetComponent<AudioListener> ();
                if (null == listener) {
                    listener = target.AddComponent<AudioListener> ();
                }
            }
            m_curAudioListener = listener;
            m_curAudioListener.enabled = true;
        }

        [LuaCallCSharp]
        /// <summary>
        /// 设置全局音效音量
        /// </summary>
        public void SetAudioEffectVolume (float volume) {
            m_globalAudioVolume = volume;

            FairyGUI.Stage.inst.soundVolume = volume;

            if (!AudioPoolMap.ContainsKey (GroupId.EAX) || null == AudioPoolMap[GroupId.EAX]) {
                return;
            }
            AudioPoolMap[GroupId.EAX].SetVolume (volume);
        }

        [LuaCallCSharp]
        /// <summary>
        /// 设置全局音乐音量
        /// </summary>
        public void SetAudioMusicVolume (float volume) {
            m_globalMusicVolume = volume;

            if (AudioPoolMap.ContainsKey (GroupId.BG) && null != AudioPoolMap[GroupId.BG])
                AudioPoolMap[GroupId.BG].SetVolume (volume);

            if (AudioPoolMap.ContainsKey (GroupId.Battle) && null != AudioPoolMap[GroupId.Battle])
                AudioPoolMap[GroupId.Battle].SetVolume (volume);
        }

        //单独拎出来的接口，清理非背景音乐的音效
        [LuaCallCSharp]
        public void ClearAuidoEff () {
            // 音效改成池子,每个播放的音效缓存10s
            //if (AudioPoolMap.ContainsKey(GroupId.EAX) && AudioPoolMap[GroupId.EAX] != null)
            //    AudioPoolMap[GroupId.EAX].ClearAllAudio();
            //AudioPoolMap[GroupId.EAX] = null;
        }

        //清理所有音乐音效
        [LuaCallCSharp]
        public void ClearAllAudio () {
            for (int i = (int) GroupId.BG; i <= (int) GroupId.EAX; i++) {
                if (AudioPoolMap.ContainsKey ((GroupId) i)) {
                    var pool = AudioPoolMap[(GroupId) i];
                    pool.ClearAllAudio ();
                    AudioPoolMap[(GroupId) i] = null;
                }
            }
        }

        //播放各种声效（战斗，人物说话）
        public AudioSourceData PlayerEAXAudio (string aduioname, string path, bool isLoop = false, bool isCanPitch = true) {
            return PlayAudio (aduioname, path, isLoop ? 1: 2, 1, GroupId.EAX, null, AudioState.Play, isCanPitch);
        }

        //播放背景音乐
        public AudioSourceData PlayerBgAudio (string aduioname, string path) {
            return PlayAudio (aduioname, path, 1, 1, GroupId.BG, null, AudioState.Play, false);
        }
        public AudioState GetGroupState (GroupId groupId) {
            if (groupId == GroupId.EAX) {
                Debug.LogError ("不支持音效类获取");
                return AudioState.NoInit;
            }
            if (AudioPoolMap[groupId] == null || AudioPoolMap[groupId].Pool.Count == 0) {
                return AudioState.NoInit;
            }

            if (AudioPoolMap[groupId].Pool.Count == 0) {
                return AudioState.NoInit;
            }

            return AudioPoolMap[groupId].Pool[0].curstate;
        }
        public void SetEXAPitch (float pitch) {
            EAXPitch = pitch;
            if (!AudioPoolMap.ContainsKey (GroupId.EAX) || AudioPoolMap[GroupId.EAX] == null || AudioPoolMap[GroupId.EAX].Pool.Count == 0) {
                return;
            }
            foreach (var adata in AudioPoolMap[GroupId.EAX].Pool) {
                if (adata.isCanPitch && adata.audiosource) {
                    adata.audiosource.pitch = pitch;
                }
            }
        }

        // Bg,Battle,这些音乐为背景因为，全局只有一个
        public void SetGroupState (GroupId groupId, AudioState astate) {
            if (!AudioPoolMap.ContainsKey (groupId) || AudioPoolMap[groupId] == null || AudioPoolMap[groupId].Pool.Count == 0) {
                return;
            }

            switch (groupId) {
                case GroupId.BG:
                case GroupId.Battle:
                    foreach (var adata in AudioPoolMap[groupId].Pool) {
                        DoAudioState (adata, astate);
                    }
                    break;
                case GroupId.EAX:
                    foreach (var adata in AudioPoolMap[groupId].Pool) {
                        DoAudioState (adata, astate);
                    }
                    break;
            }
        }

        public void SetAudioState (GroupId groupId, string audioname, AudioState astate) {
            if (!AudioPoolMap.ContainsKey (groupId) || AudioPoolMap[groupId] == null || AudioPoolMap[groupId].Pool.Count == 0) {
                return;
            }

            foreach (var adata in AudioPoolMap[groupId].Pool) {
                if(null != adata.audiosource.clip && adata.audiosource.clip.name == audioname)
                {
                    DoAudioState (adata, astate);
                }
            }
        }

        /// <summary>
        /// 播放声音
        /// </summary>
        public AudioSourceData PlayAudio (string audioname, string resPath, int musictype, float volume, GroupId groupId, Transform slot, AudioState option, bool isCanPitch) {
            if (string.IsNullOrEmpty (audioname) || string.IsNullOrEmpty(resPath)) {
                return null;
            }

            string path = resPath;

            //if (groupId != GroupId.EAX)
            //{
            //    Debug.LogError("play audio :" + audioname);
            //}

            // 是否为3d音乐
            bool is3d = slot != null;
            // 是否为循环音乐
            bool isLoop = musictype == 1;
            // 获取音源数据
            AudioSourceData asdata = AudioSource (isLoop, volume, groupId, is3d, audioname);

            if (null == asdata) {
                if (groupId != GroupId.EAX) {
                    Debug.LogError ("play audio 2:" + audioname);
                }
                return null;
            }

            asdata.audiosource.playOnAwake = false;
            asdata.groupId = groupId;
            asdata.groupname = GroupIdMap[groupId];
            asdata.isLoop = isLoop;
            asdata.curstate = AudioState.NoInit;
            asdata.isCanPitch = isCanPitch;

            // 父对象处理
            if (is3d) {
                asdata.slot.transform.parent = slot;
                asdata.slot.transform.localPosition = Vector3.zero;
            }
            // 音源加载
            if (asdata.audiosource.clip) {
                // 需要重新加载
                bool needreload = false;
                // 如果为循环音乐
                if (isLoop) {
                    if (asdata.audiosource.clip.name == audioname) {
                        if (asdata.curstate != option) {
                            DoAudioState (asdata, option);
                        }

                        return asdata;
                    } else {
                        needreload = true;
                    }
                } else {
                    //Debug.LogError("获取缓存名字 : " + asdata.audiosource.clip.name + "  需要播放的名字 :" + audioname);
                    if (asdata.audiosource.clip.name == audioname) {
                        DoAudioState (asdata, option);
                    } else {
                        needreload = true;
                    }
                }
                //Debug.LogError("Need Reload : " + needreload);
                if (needreload) {
                    // 执行卸载

                    asdata.audiosource.clip.UnloadAudioData ();
                    asdata.audiosource.clip = null;
                    //                    GamePoolManager.Instance.GetFromPool("audioPool", path, (obj) =>
                    //                    {                 
                    //                        if (obj != null)
                    //                        {
                    //                            AudioOption(asdata, (AudioClip)obj, option, path);     
                    //                        }
                    //                    }, Vector3.zero, true);
                    //                    // 加载资源
                    //                    ResourceMgr.Instance.Load(path, (obj) =>
                    //                   {                 
                    //                       if (obj != null)
                    //                       {
                    //                           AudioOption(asdata, (AudioClip)obj, option, path);     
                    //                       }
                    //                   }, false, audioname, typeof(AudioClip));
                    AudioAssetBundle audioAb = null;
                    if (AudioAssetBundles.TryGetValue (audioname, out audioAb)) {
                        audioAb.AddAction (path, audioname, clip => {
                            if (clip != null) {
                                AudioOption (asdata, clip, option, path);
                            }
                        });
                    } else {
                        audioAb = new AudioAssetBundle ();
                        AudioAssetBundles.Add (audioname, audioAb);

                        audioAb.AddAction (path, audioname, clip => {
                            if (clip != null) {
                                AudioOption (asdata, clip, option, path);
                            }
                        });
                    }
                }
            } else {
                //                ResourceMgr.Instance.Load(path, (obj) =>
                //                {
                //                    if (obj != null)
                //                    {
                //                        AudioOption(asdata, (AudioClip)obj, option, path);   
                //                    }
                //                }, false, audioname, typeof(AudioClip));
                AudioAssetBundle audioAb = null;
                if (AudioAssetBundles.TryGetValue (audioname, out audioAb)) {
                    audioAb.AddAction (path, audioname, clip => {
                        if (clip != null) {
                            AudioOption (asdata, clip, option, path);
                        }
                    });
                } else {
                    audioAb = new AudioAssetBundle ();
                    AudioAssetBundles.Add (audioname, audioAb);

                    audioAb.AddAction (path, audioname, clip => {
                        if (clip != null) {
                            AudioOption (asdata, clip, option, path);
                        }
                    });
                }
            }
            return asdata;
        }

        void trydoSLogic (AudioSourceData asdata, GroupId groupId) {
            if (asdata.isLoop == false) {
                loopAuidoItem = new LoopAuidoItem ();
                loopAuidoItem.tick = 0;
                loopAuidoItem.lifetime = asdata.audiosource.clip.length;
                loopAuidoItem.hasDoFadeOut = false;
                asdata.audiosource.loop = true;

            }
        }

        private AudioSourceData AudioSource (bool isLoop, float volume, GroupId groupId, bool is3D, string audioname) {
            if (!AudioPoolMap.ContainsKey (groupId)) {
                var pool = new AudioPool (GroupIdMap[groupId], gameObject.transform);
                AudioPoolMap.Add (groupId, pool);
            }

            if (AudioPoolMap[groupId] == null)
                AudioPoolMap[groupId] = new AudioPool (GroupIdMap[groupId], gameObject.transform);

            AudioSourceData asdata = null;
            switch (groupId) {
                case GroupId.BG:
                case GroupId.Battle:

                    if (AudioPoolMap[groupId].Pool.Count == 0) {
                        AudioPoolMap[groupId].AddAudioSource (false);
                    }

                    asdata = AudioPoolMap[groupId].Pool[0];
                    asdata.audiosource.volume = volume * m_globalMusicVolume;
                    break;

                case GroupId.EAX:

                    asdata = AudioPoolMap[groupId].GetAudioSource (is3D, audioname);
                    if (asdata == null) {
                        AudioPoolMap[groupId].AddAudioSource (is3D);
                        asdata = AudioPoolMap[groupId].Pool[AudioPoolMap[groupId].Pool.Count - 1];
                        asdata.audiosource.loop = false;
                    }
                    asdata.lifeTime = EAXAudioLifeTime;
                    asdata.audiosource.volume = volume * m_globalAudioVolume;
                    break;
            }
            asdata.audiosource.loop = isLoop;

            return asdata;
        }
        private void AudioGroupId (AudioSourceData asdata, AudioMixerGroup[] groups, ref int mixerGroupId) {
            if (groups.Length > 1) {
                mixerGroupId++;
                if (mixerGroupId >= groups.Length) {
                    mixerGroupId = 1;
                }
                asdata.audiosource.outputAudioMixerGroup = groups[mixerGroupId];
            } else {
                asdata.audiosource.outputAudioMixerGroup = groups[0];
            }
        }
        private void AudioOption (AudioSourceData asdata, AudioClip clip, AudioState option, string respath) {
            if (clip == null) {
#if UNITY_EDITOR

                Debug.LogWarning ("没有资源 声音:" + respath);
                return;
#endif
            }

            if (m_audioMixer != null && !string.IsNullOrEmpty (asdata.groupname)) {
                AudioMixerGroup[] groups = m_audioMixer.FindMatchingGroups (asdata.groupname);
                if (groups.Length > 0) {
                    // 背景音乐，打开时，关闭上一背景音乐
                    if (asdata.groupId == GroupId.BG) {
                        AudioGroupId (asdata, groups, ref m_bgMixerGroupId);
                    } else {
                        asdata.audiosource.outputAudioMixerGroup = groups[0];
                    }
                }
            }

            asdata.respath = respath;
            asdata.audiosource.clip = clip;

            // 改变音源状态
            DoAudioState (asdata, option);
        }
        /// <summary>
        /// 音源状态切换
        /// </summary>
        public void DoAudioState (AudioSourceData asdata, AudioState option) {
            // stupid 1 not used,use stupid 2
            if (asdata == null || asdata.curstate == AudioState.Stop || (asdata.curstate == AudioState.Play && asdata.audiosource.isPlaying == false)) {
                return;
            }
            asdata.curstate = option;
            switch (option) {
                case AudioState.Play:
                    asdata.audiosource.pitch = 1;
                    if (asdata.groupId == GroupId.EAX) {
                        asdata.audiosource.Play ();
                        if (asdata.isCanPitch) {
                            asdata.audiosource.pitch = EAXPitch;
                        }
                    } else if (asdata.groupId == GroupId.BG) {
                        StopAllCoroutines ();
                        StopBgAndBattle (GroupId.Battle); //防止背景音乐还未停止，就直接StopAllCoroutines导致重音
                        SetAudioMusicVolume (m_globalMusicVolume);
                        asdata.audiosource.Play ();
                        trydoSLogic (asdata, GroupId.BG);
                        StartCoroutine (AudioCrossFade (asdata, option, AudioCrossType.FadeIn));
                    } else if (asdata.groupId == GroupId.Battle) {
                        StopAllCoroutines ();
                        StopBgAndBattle (GroupId.BG);
                        asdata.audiosource.Play ();
                        trydoSLogic (asdata, GroupId.Battle);
                        StartCoroutine (AudioCrossFade (asdata, option, AudioCrossType.FadeIn));
                    }
                    break;
                case AudioState.UnPause:
                    asdata.audiosource.UnPause ();
                    asdata.curstate = AudioState.Play;
                    break;
                case AudioState.Pause:
                    asdata.audiosource.Pause ();
                    break;
                case AudioState.Stop:
                    if (asdata.groupId == GroupId.BG || asdata.groupId == GroupId.Battle) {
                        StartCoroutine (AudioCrossFade (asdata, option, AudioCrossType.FadeOut));
                    } else
                        asdata.audiosource.Stop ();
                    break;
            }

        }
        /// <summary>
        /// 暂停音乐播放
        /// </summary>
        /// <param name="groupId"></param>
        public void PauseBGAudio () {
            SetGroupState (GroupId.BG, AudioState.Pause);
            SetGroupState (GroupId.Battle, AudioState.Pause);
        }
        /// <summary>
        /// 恢复音乐播放
        /// </summary>
        /// <param name="groupId"></param>
        public void ResumeBGAudio () {

            SetGroupState (GroupId.BG, AudioState.UnPause);
            SetGroupState (GroupId.Battle, AudioState.UnPause);
        }

        /// <summary>
        /// 停止音效播放
        /// </summary>
        public void StopEAX (string audioname) {
            SetAudioState(GroupId.EAX, audioname, AudioState.Stop);
        }

        private System.Collections.IEnumerator AudioCrossFade (AudioSourceData asdata, AudioState option, AudioCrossType crossType) {
            if (asdata == null || asdata.audiosource == null) {
                yield break;
            }

            float startvolume = asdata.audiosource.volume;

            if (crossType == AudioCrossType.FadeIn) {
                asdata.audiosource.volume = 0;
            }

            bool checkend = crossType == AudioCrossType.FadeIn ? asdata.audiosource.volume<startvolume : asdata.audiosource.volume> 0;

            switch (option) {
                case AudioState.Play:
                    asdata.curstate = AudioState.FadeIn;
                    asdata.audiosource.Play ();
                    break;
                case AudioState.UnPause:
                    asdata.curstate = AudioState.FadeOut;
                    asdata.audiosource.UnPause ();
                    break;
            }

            while (asdata != null && asdata.audiosource != null && checkend) {
                if (crossType == AudioCrossType.FadeIn) {
                    //Debug.LogError("Set Volume + " + asdata.audiosource.volume);
                    asdata.audiosource.volume += startvolume / 12;
                } else {
                    //Debug.LogError("Set Volume - " + asdata.audiosource.volume);
                    asdata.audiosource.volume -= startvolume / 12;
                }
                checkend = crossType == AudioCrossType.FadeIn ? asdata.audiosource.volume<startvolume : asdata.audiosource.volume> 0;
                yield return new WaitForSecondsRealtime (0.1f);
            }

            //Debug.LogError("audio is :" + asdata.audiosource);

            if (asdata == null || asdata.audiosource == null) {
                yield break;
            }
            switch (option) {
                case AudioState.Pause:
                    asdata.audiosource.Pause ();
                    break;
                case AudioState.Stop:
                    asdata.audiosource.Stop ();
                    break;
            }
            asdata.curstate = option;
            asdata.audiosource.volume = startvolume;
        }

        //直接停止背景音乐
        void StopBgAndBattle (GroupId groupId) {
            if (!AudioPoolMap.ContainsKey (groupId) || AudioPoolMap[groupId] == null || AudioPoolMap[groupId].Pool.Count == 0) {
                return;
            }
            foreach (var adata in AudioPoolMap[groupId].Pool) {
                adata.audiosource.Stop ();
                adata.curstate = AudioState.Stop;
                adata.audiosource.volume = 0;
            }
        }

    }
    /// <summary>
    /// 音源数据
    /// </summary>
    public class AudioSourceData {
        // 路径
        public string respath;
        // 挂点
        public GameObject slot;
        // 音源
        public AudioSource audiosource;
        // 默认音量
        public float defaultvolume;
        // 是否为3d
        public bool is3d = false;
        // 组
        public GroupId groupId;
        public string groupname;

        public AudioState curstate;

        public bool isLoop = false;

        public float lifeTime = 0;

        public bool isCanPitch = true;
    }
    /// <summary>
    /// 音源池
    /// </summary>
    public class AudioPool {
        private GameObject mRoot;
        public List<AudioSourceData> Pool { private set; get; }
        public AudioPool (string poolname, Transform parent) {
            mRoot = new GameObject (poolname);
            mRoot.transform.parent = parent;
            mRoot.transform.localPosition = Vector3.zero;

            Pool = new List<AudioSourceData> ();
        }

        // 添加音源
        public void AddAudioSource (bool is3d) {
            AudioSourceData asdata = new AudioSourceData ();
            asdata.defaultvolume = 1.0f;
            if (is3d) {
                asdata.slot = new GameObject ("3dSound");
                asdata.slot.transform.parent = mRoot.transform;
                asdata.audiosource = asdata.slot.AddComponent<AudioSource> ();
                asdata.audiosource.rolloffMode = AudioRolloffMode.Linear;
                asdata.audiosource.spatialBlend = 1;
            } else {
                asdata.slot = mRoot;
                asdata.audiosource = asdata.slot.AddComponent<AudioSource> ();
                asdata.audiosource.spatialBlend = 0;
            }
            asdata.is3d = is3d;

            Pool.Add (asdata);
        }

        public void ClearAllAudio () {
            foreach (var audio in Pool) {
                if (audio.audiosource != null) {
                    Object.Destroy (audio.audiosource);
                    audio.audiosource = null;
                }
            }
            Pool.Clear ();
            if (mRoot) {
                GameObject.Destroy (mRoot);
            }
        }

        // 获取空闲音源
        public AudioSourceData GetAudioSource (bool is3d, string audioname) {
            AudioSourceData asdata = null;
            // 取不在使用的音源组件
            for (int i = Pool.Count - 1; i >= 0; i--) {
                if (null == Pool[i].slot) {
                    Pool.RemoveAt (i);
                    continue;
                }
                if (Pool[i].curstate != AudioState.Pause && Pool[i].audiosource.isPlaying == false) {
                    bool canUse = false;
                    if (Pool.Count < AudioManager.Instance.EAXMaxPoolCount) {
                        // 池子里的音乐没有超过上限的话，那么只去复用已有的音乐
                        if (Pool[i].audiosource.clip == null ||
                            (Pool[i].audiosource.clip != null && Pool[i].audiosource.clip.name == audioname)) {

                            //Debug.LogError("获取到一个没有播放的缓存声音 " + audioname + " clip is :"+ Pool[i].audiosource.clip + " 当前缓存池大小:" + Pool.Count);
                            canUse = true;

                        }
                    } else {
                        // 超过上限了，那么直接取没有播放的来播放
                        canUse = true;
                        //Debug.LogError("超过上限了，取没有播放的音乐重新读盘覆盖,当前缓存大小 "+ Pool.Count);
                    }

                    if (canUse) {
                        if (Pool[i].is3d == is3d) {
                            asdata = Pool[i];
                        }
                        if (Pool[i].is3d) {
                            Pool[i].slot.transform.parent = mRoot.transform;
                        }

                        if (asdata != null) {
                            return asdata;
                        }
                    }

                }
            }

            return asdata;
        }
        // 获取空闲音源
        public void SetVolume (float volume) {
            foreach (var asource in Pool) {
                if (null != asource.audiosource && asource.audiosource.clip != null) {
                    asource.audiosource.volume = asource.defaultvolume * volume;
                }
            }
        }
    }

    public class AudioAssetBundle {
        private AudioClip clip;
        private string audioName;
        private List<Action<AudioClip>> cbs = new List<Action<AudioClip>> ();
        private bool inLoad = false;
        public void SetAudioClip (AudioClip clip) {
            this.clip = clip;

            foreach (var cb in cbs) {
                cb (clip);
            }
            cbs.Clear ();
            AudioManager.Instance.AudioAssetBundles.Remove (audioName);
        }

        public void AddAction (string path, string audioName, Action<AudioClip> cb) {
            if (clip) {
                cb (clip);
                return;
            }

            this.audioName = audioName;
            cbs.Add (cb);
            if (!inLoad) {
                inLoad = true;
                Addressables.LoadAssetAsync<AudioClip>(path).Completed += (h)=> {
                    inLoad = false;
                    if (h.Result == null) {
                        return;
                    }
                    SetAudioClip (h.Result);
                };
            }
        }
    }
}