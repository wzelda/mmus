using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using XLua;
using UnityEngine.Video;
using FairyGUI;

namespace LPCFramework
{
    [LuaCallCSharp]
    public class VideoCtrl : SingletonMonobehaviour<VideoCtrl>
    {
        public Text m_content;
        // 字幕对象
        public GameObject m_subTitleObj;
        // 提示对象
        public GameObject m_tipsObj;

        private Dictionary<string, VideoClip> m_videoClips = new Dictionary<string, VideoClip>();

        private VideoPlayer m_videoPlayer = null;

        private AudioSource m_audioSource = null;

        public System.Action OnVideoBegin = null;
        public System.Action OnVideoPlay = null;
        public System.Action OnVideoEnd = null;

        private bool m_couldSkip = false;

        void Awake()
        {
            Initialize();
        }

        public bool IsPlaying()
        {
            if (null == m_videoPlayer)
                return false;

            return m_videoPlayer.isPlaying;
        }

        public void PreloadVideo(string url)
        {
            if (string.IsNullOrEmpty(url))
            {
                return;
            }
            if (null == m_videoClips)
            {
                m_videoClips = new Dictionary<string, VideoClip>();
            }
            ResourceMgr.Instance.Load(url, (Object clip) =>
            {
                if (null == clip)
                {
                    return;
                }
                m_videoClips.Add(url, clip as VideoClip);
            });
        }

        public void PlayVideo(string videoUrl, bool isLoop = false, bool couldSkip = false)
        {
            if (string.IsNullOrEmpty(videoUrl) || null == m_videoPlayer)
                return;

            if(LuaUtils.IsUrl(videoUrl))
            {
                m_videoPlayer.url = videoUrl;
                m_couldSkip = couldSkip;
                m_videoPlayer.isLooping = isLoop;
                m_videoPlayer.Prepare();
                return;
            }

            VideoClip clip = null;
            if (m_videoClips.ContainsKey(videoUrl))
            {
                clip = m_videoClips[videoUrl];
                SetVideo(clip, isLoop, couldSkip);
            }
            else {
                ResourceMgr.Instance.Load(videoUrl, (Object r) =>
                {
                    if (r == null)
                        return;

                    clip = m_videoClips[videoUrl] = (VideoClip)r;
                    SetVideo(clip, isLoop, couldSkip);
                });
            }
        }

        public void Stop()
        {
            if (null != m_videoPlayer && null != m_videoPlayer.clip)
            {
                m_videoPlayer.Stop();

                m_videoPlayer.clip = null;

                if (null != OnVideoEnd)
                    OnVideoEnd.Invoke();
            }
        }

        // 跳过
        public void Skip()
        {
            if (m_couldSkip)
                Stop();
        }

        public void Play()
        {
            if (null != m_videoPlayer && null != m_videoPlayer.clip)
                m_videoPlayer.Play();
        }

        // 释放资源
        public void Release()
        {
            if (null != m_videoPlayer)
            {
                m_videoPlayer.clip = null;

                // 释放掉RenderImage占用的硬件资源
                if (null != m_videoPlayer.targetTexture)
                    m_videoPlayer.targetTexture.Release();

                // 释放掉缓存的视频
                if (null != m_videoClips)
                    m_videoClips.Clear();
            }
        }
        // 设置字幕提示可见性
        public void SetSubtitleTipVisible(bool value)
        {
            if (null != m_tipsObj)
                m_tipsObj.SetActive(value);
        }

        // 设置字幕可见性
        public void SetSubtitleVisible(bool value)
        {
            if (null != m_subTitleObj)
                m_subTitleObj.SetActive(value);
        }

        // 通过配置播放字幕
        public void PlaySubtitle(float strat, float end, string content)
        {
            StartCoroutine(IEPlaySubTitle(strat, end, content));
        }

        // 停止字幕并隐藏
        public void StopSubtitle()
        {
            StopAllCoroutines();
            ClearSubtitleContent();
            SetSubtitleVisible(false);
        }

        // 清空字幕
        private void ClearSubtitleContent()
        {
            if (null != m_content)
                m_content.text = string.Empty;
        }

        // 协程来自动播放，自动隐藏
        private IEnumerator IEPlaySubTitle(float strat, float end, string content)
        {
            if (Application.isFocused == false)
                yield return null;

            if (strat > 0)
                yield return new WaitForSeconds(strat);

            m_content.text = content;

            if (end > 0)
                yield return new WaitForSeconds(end - strat);

            m_content.text = string.Empty;
        }

        private void Initialize()
        {
            m_videoPlayer = gameObject.AddComponentIfNotExist<VideoPlayer>();
            m_audioSource = gameObject.AddComponentIfNotExist<AudioSource>();

            // 设置videoPlayer属性
            m_videoPlayer.playOnAwake = false;
            m_videoPlayer.waitForFirstFrame = true;
            m_videoPlayer.skipOnDrop = true;
            m_videoPlayer.audioOutputMode = VideoAudioOutputMode.AudioSource;
            m_videoPlayer.EnableAudioTrack(0, true);
            m_videoPlayer.SetTargetAudioSource(0, m_audioSource);

            m_videoPlayer.prepareCompleted += VideoPrepareCompleted;
            m_videoPlayer.started += VideoStarted;
            m_videoPlayer.loopPointReached += VideoLoopPointReached;

            // 设置audioSource属性
            m_audioSource.playOnAwake = false;

            SetSubtitleTipVisible(false);
            SetSubtitleVisible(false);
        }

        void OnDestroy()
        {
            Release();

            if (null != m_videoClips)
                m_videoClips.Clear();

            // 去除videoPlayer的回调事件
            m_videoPlayer.loopPointReached -= VideoLoopPointReached;
            m_videoPlayer.prepareCompleted -= VideoPrepareCompleted;

            m_videoPlayer = null;
            m_audioSource = null;
            OnVideoEnd = null;
            OnVideoBegin = null;
            OnVideoPlay = null;
        }

        private void SetVideo(VideoClip c, bool isLoop, bool couldSkip)
        {
            if (null == m_videoPlayer)
                return;

            // 视频塞给videoPlayer
            m_videoPlayer.clip = c;
            m_couldSkip = couldSkip;
            m_videoPlayer.isLooping = isLoop;
            m_videoPlayer.Prepare();
        }

        private void VideoLoopPointReached(VideoPlayer vp)
        {
            if (vp.isLooping)
                return;

            m_videoPlayer.clip = null;

            StartCoroutine(WaitToCallEndCallback());
        }

        private void VideoPrepareCompleted(VideoPlayer vp)
        {
            vp.Play();

            StartCoroutine(WaitToCallReadyCallback());
        }

        private void VideoStarted(VideoPlayer vp)
        {
            vp.Play();

            StartCoroutine(WaitToCallStartCallback());
        }

        private IEnumerator WaitToCallEndCallback()
        {
            yield return new WaitForSeconds(Time.deltaTime);

            if (null != OnVideoEnd)
                OnVideoEnd.Invoke();
        }

        private IEnumerator WaitToCallReadyCallback()
        {
            yield return new WaitForSeconds(Time.deltaTime);

            if (null != OnVideoBegin)
                OnVideoBegin.Invoke();
        }

        private IEnumerator WaitToCallStartCallback()
        {
            yield return new WaitForSeconds(Time.deltaTime);

            if (null != OnVideoPlay)
                OnVideoPlay.Invoke();
        }
    }
}