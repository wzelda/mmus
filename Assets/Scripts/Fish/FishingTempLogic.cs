using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using DG.Tweening.Plugins.Options;
using DG.Tweening.Core;

[DisallowMultipleComponent]
public class FishingTempLogic : MonoBehaviour
{

    private enum PlayModeEnum
    {
        None,
        Auto,
        PlayerControl,
        Box,
    }
    private enum AutoStageEnum
    {
        None,
        Throw,
        Simulate,
        PullBack,
        PullUp,
        Show,
    };

    private enum PlayStageEnum
    {
        None,
        WaitToThrow,
        Throw,
        SimulateFight,
        Jump,
        PullBack,
        PullUp,
        Show,
    };

    private enum BoxStageEnum
    {
        None,
        Throw,
        PullBack,
    };

    //用于ui界面中的不同状态显示
    private enum UIStateEnum
    {
        None = 0,
        WaitToThrow = 1,
        Throw = 2,
        WaitFishBite = 3,
        FishBite = 4,
        Fight = 5,
        CriticalStrikeChance = 6,
        InAir = 7,
        ShowHunter = 8,
        PullBack = 9,
        PullUp = 10,
        Show = 11,
        Crit = 12,
        ShowGold=13,
        HuntStart=14,
        HunterJump =15,
    }

    private enum HuntStage
    {
        None,
        Jump,
        Bite,
        Follow,
    }
     private enum EventType
    {
        Jump = 0,
        Hunt = 1,
    };

    //SimulateFight模拟时 鱼儿移动Normal 跃起Jump 等待鱼上钩WaitFishBite 鱼咬钩FishBite 和玩家对抗PlayerFight
    public enum FishState
    {
        Normal = 0,
        Jump = 1,
        WaitFishBite = 2,
        FishBite = 3,
        PlayerFight = 4,
    }

    private enum RodAnimationState
    {
        Normal,
        Throw,
    }

    private enum FishAnimationState
    {
        JumpOut,
        DamageHit,
        FightBite,
        FightDefault,
        FightFinish,
        FightWeakly,
    }

    //特效表现得类型
    private enum EffectState
    {
        EnterWater,
        JumpOut,
        EnterWaterBig,
        JumpOutBig,
        Move,
        Stay,
        Crit,
        LureEnterWater,
        PullUp,
    }
    public class ShowData
    {
        public int Index = 0;//顺序id
        public FishState State = FishState.Normal;
        public float Time = 0f;//持续时间
        public float AddForceSec = 0f;//每秒增加的力度
         public float FinalForce = 0f;//最终力度
        public float InitSpeed = 0f;//初始力度
    }
    private List<ShowData> ShowList = new List<ShowData>();
    private ShowData CurrentShowData;
    private int MaxIndex;

    // 鱼饵Tranform
    public Transform LureTranform;
    private Rigidbody LureRigidbody;
    /// <summary>
    /// 鱼线起点
    /// </summary>
    public Transform LineStartTransform;
    public Transform StartBiteTransform;
    public Transform StartMoveTransform;
    public Transform PullUpTransform;
    public float AddOffsetForce = 5;
    public float MaxLeftOffset = 8;
    public float MaxRightOffset = 8;
    public float ShowLineTime = 0.5f;
    public float PullBackTime = 2f;
    public float FishShowTime = 0.2f;
    public float TurnTime = 0f;
    public float TurnNeedTime = 0.8f;
    public float CritTurnNeedTime = 0.5f;
    public Transform FishingRod;
    public Transform FishingRodRoot;
     public Transform EffectPos;
    public Transform RodHead;
    private Animator FishingRodAnimator;
    private float CurrentTime = 0;
    private float EffectTimeNum = 0;
    private AutoStageEnum CurrentState = AutoStageEnum.None;
    private PlayStageEnum CurrentPlayState = PlayStageEnum.None;
    private BoxStageEnum CurrentBoxState = BoxStageEnum.None;
    private PlayModeEnum PlayMode = PlayModeEnum.None;
    private float CompareNum = 0;
    private bool IsTurnLeft = true;
    public float G = 9.8f;
    //为了表现加速度设计为越来越小
    public float A = 0;
    private float CurrentJumpSpeed = 0;
    public float WaterY = -0.95f;
    public GameObject EnterWaterEffect;
    public GameObject CritEffect;
    public GameObject JumpOutEffect;
    public GameObject FishMoveEffect;
    public GameObject SkillEffect;
    public GameObject WaitEffect;
    public GameObject LureEnterWaterEffect;
    public Transform FishPrefab;
    public Transform FishMouse;
    private Animator FishAnimator;
    public float InitPullSpeed = 10;
    public float PullTimeScale = 0.6f;
    public Vector3 CastForce = new Vector3(0f, 200f, -510f);
    public Vector3 CastForceEX = new Vector3(0f, 700f, -700f);
    private Vector3 RootToLueVector;
    private Vector3 RootToTopVector;
    private Vector3 ANormalize;
    private Vector3 AngleVector;
    private float Angle = 0f;
    private bool RopeThrowed = false;
    private bool RopeFollowDown = false;
    public FishingRope FishingLine;
    
    private float RodForce = 0;
    private Vector3 CurrentVector;
    private Vector3 CurrentFishVector;
    private bool Jumped;
    public static FishingTempLogic Inst;
    private System.Action AutoFishCallBack;
    private System.Action<int> FishUICallBack;
    private System.Action<int> AudioCallBack;
    private System.Action<float> UpdateUIHp;
    private System.Action<int> CritDamage;
    private float InitFishHP = 10000;
    private float CurrentFishHP = 0;
    private float NormalDamage = 300;
    private List<float> EventHpPers = new List<float>{0.7f,0.4f};
    private List<int> EventHpTypes = new List<int>{0,0};
    private List<float> EventHpValues = new List<float>();
    private List<int> EventDamages = new List<int>{1699,1699};
    private Vector3 offsetVector;
    private int CurrentEventIndex = 0;
    private int MaxEventIndex = 0;
    private bool Touching = false;
    //玩家施加力度
    private float PlayerAddForce = 0.4f;
    //鱼竿回弹力度
    private float BackForce = 0.8f;
    private bool CanCrit = false;
    private bool InputCrit = false;
    private bool Critting = false;
    private bool AngleChanged = false;
    private float CritChangeAngle = -35;
    private float RodAngle = 0;
    private float CritTime = 0;
    private float LerpValue = 0;
    private Vector3 CritAngleVector = new Vector3();
    private float TriggerCritSpeedValue = 0.2f;
    private float PlayModeJumpSpeed = 10;
    private float FightJumpAddForce = 1f;
    public Transform BoxHead;
    public Transform AdBox;
    public Transform NormalBox;
    public Transform BoxStart;
    public Transform BoxEnd;
    private float BoxShowTime = 15f;
    private bool BoxMoveStart = false;
    private float BoxMoveTime = 0;

    private float distance = 0;
    private Vector3 startPos;
    private Vector3 middlePos;
    private Vector3 endPos;
    private Vector3 resultPos = new Vector3();
    // 已经飞行的时间
    private float flyTime = 0;
    // 在空中飞行的整个时间
    private float flyMaxTime = 2f; 
    // Start is called before the first frame update

    // 捕食者
    private Transform HunterSlotTf;
    private Transform HunterTf;
    private Transform HunterMouseTf;
    private Animator HunterAnim;
    private bool IsHunt;
    private bool Huntting;
    private bool Huntted;
    private float HuntJumpTime = 0.8f;
    private float HunterBiteTime = 0.15f;
    private HuntStage HStage = HuntStage.None;
    private float HuntTimeScale = 0;
    private bool HuntJumpEffectPlayed = false;
    private bool HuntEnterWaterEffectPlayed = false;
    private float BitePrepareTime = 0;
    private bool BitePrepared = false;
    private float HpUpdateTime = 0;
    private float HpHitTime = 0;
    void Start()
    {
        // AutoFishStart();
        FishingLine.SetHeadTail(LineStartTransform,LureTranform);
        FishingLine.SetState(FishingRope.eState.Hide);
    }
    private void Awake()
	{
		Inst = this;
    }

    public void SetAutoCallBack(System.Action callBack)
    {
        AutoFishCallBack = callBack;
    }
    public void SetFishCallUI(System.Action<int> callBack)
    {
        FishUICallBack = callBack;
    }

    public void SetFishCallAudio(System.Action<int> callBack)
    {
        AudioCallBack = callBack;
    }

    public void SetUpdateUIHp(System.Action<float> callBack,float hitTime)
    {
        UpdateUIHp = callBack;
        HpHitTime = hitTime;
    }
    public void SetCritDamage(System.Action<int> callBack)
    {
        CritDamage = callBack;
    }
    void FishCallUI(UIStateEnum state)
    {
        if (FishUICallBack != null)
        {
            FishUICallBack((int)state);
        }
    }

    void PlayAudio(int num)
    {
        if (AudioCallBack != null)
        {
            AudioCallBack(num);
        }
    }

    public void SetFishInstance(GameObject fishInstance,string mousePath)
    {
        if (fishInstance != null)
        {
            fishInstance.SetActive(true);
            FishAnimator = fishInstance?.GetComponentInChildren<Animator>();
            FishMouse = fishInstance?.transform?.Find(mousePath);
            if (FishMouse == null)
            {
                FishMouse = fishInstance.transform;
            }
        }
    }

    public void SetHunterInstance(GameObject hunterInstance,string mousePath)
    {

        if (HunterSlotTf == null)
        {
            HunterSlotTf = new GameObject().transform;
        }
        if (hunterInstance != null)
        {
            hunterInstance.SetActive(true);
            HunterAnim = hunterInstance?.GetComponentInChildren<Animator>();
            HunterTf = hunterInstance.transform;
            HunterMouseTf = hunterInstance?.transform?.Find(mousePath);
            HunterMouseTf = HunterMouseTf == null ? HunterTf:HunterMouseTf;
            HunterTf.SetParent(HunterSlotTf);
            HunterTf.localPosition = Vector3.zero;
            HunterTf.localEulerAngles = Vector3.zero;
            HunterSlotTf.gameObject.SetActive(false);
        }
    }

    public void ClearHunterInstance()
    {
        if (FishPrefab)
        {
            FishPrefab.SetParent(EffectPos);
            FishPrefab.localPosition = Vector3.zero;
            FishPrefab.localEulerAngles = Vector3.zero;
            
        }
        if (HunterTf)
        {
            HunterTf.gameObject.SetActive(false);
            HunterTf.SetParent(FishPrefab);
            HunterTf.localPosition = Vector3.zero;
            HunterTf.localEulerAngles = Vector3.zero;
        }
        Huntted = false;
        Huntting = false;
        HideFish();
    }
    void InitHunt ()
    {
        startPos =  FishPrefab.position;
        startPos.y = WaterY - 3;
        startPos.x = startPos.x -5f;
        startPos.z = startPos.z -5f;
        endPos = FishPrefab.position - offsetVector;
        // endPos.z = endPos.z - Vector3.Distance(HunterTf.position,HunterMouseTf.position);
        // endPos.z = endPos.z;
        // var vector = middlePos - startPos;
        HunterSlotTf.position = startPos;
        // HunterSlotTf.localRotation = Quaternion.Euler(0,30,0);
        middlePos = (endPos - startPos)*0.75f + startPos;
        middlePos.y = endPos.y;
        flyTime = 0;
        HuntJumpEffectPlayed = false;
        HuntEnterWaterEffectPlayed = false;
        HStage = HuntStage.None;
        
        Huntting = true;
        //硬编 现在需要12帧的时间
        BitePrepareTime = HuntJumpTime - 12 * Time.fixedDeltaTime;
    }

    public void SetRodInstance(Transform rodInstance)
    {
        FishingRod = rodInstance;
        FishingRodAnimator = FishingRod?.GetComponent<Animator>();
    }
    
    public void SetLureInstance(Transform lureInstance)
    {
        LureTranform = lureInstance;
        LureRigidbody = LureTranform?.GetComponent<Rigidbody>();
    }

    public void AutoFishStart()
    {
        CurrentState = AutoStageEnum.None;
        PlayMode = PlayModeEnum.Auto;
    }

    public void PlayModeStart(int _Hp,int _NormalDamage,List<float> _EventHpPers,List<int> _EventTypes,List<int> _EventDamages,Vector3 _offsetVector)
    {
        CurrentPlayState = PlayStageEnum.None;
        PlayMode = PlayModeEnum.PlayerControl;
        InitFishHP = _Hp;
        NormalDamage = _NormalDamage;
        EventHpPers = _EventHpPers;
        EventHpTypes = _EventTypes;
        EventDamages = _EventDamages;
        offsetVector = _offsetVector;
        InitAll();
        HideEffect(EffectState.Move);
        SetRodAnimation(RodAnimationState.Normal);
        SetRodPower(0);
        LureRigidbody.velocity = Vector3.zero;
		LureRigidbody.useGravity = false;
        SetLurePostion(LineStartTransform.position);
        FishingLine.SetState(FishingRope.eState.HookSet);
    }
    public void PlayerThrow(Vector3 vector3)
    {
        DoTrow();
    }
    public void PlayerTouchBegin()
    {
        Touching = true;
    }

    public void PlayerTouchEnd()
    {
       Touching = false;
    }

    public void CritSuccess()
    {
       InputCrit = true;
    }

    public void BoxModeStart()
    {
        CurrentBoxState = BoxStageEnum.None;
        PlayMode = PlayModeEnum.Box;
        BoxMoveStart = false;
        InitAll();
        SetRodAnimation(RodAnimationState.Normal);
        SetRodPower(0);
        LureRigidbody.velocity = Vector3.zero;
		LureRigidbody.useGravity = false;
        SetRodRotation(Vector3.zero);
        SetRodHeadRotation(new Vector3(0,GetBoxAngle(),0));
        SetLurePostion(LineStartTransform.position);
        FishingLine.SetState(FishingRope.eState.HookSet);
    }
    public float GetBoxAngle()
    {
        var  vector = BoxHead.position - FishingRodRoot.position;
        vector.y = 0;
        Angle = Vector3.Angle(vector,Vector3.forward);
        if (vector.x < 0)
        {
            return 180 - Angle ;
        }
        else
        {
            return Angle -180;
        }
    }

    public void CreateNormalBox()
    {
        if (BoxStart == null || BoxMoveStart)
        {
            return;
        }
        SetBoxPosion(BoxStart.position);
        SetNormalBoxActive(true);
        SetAdBoxActive(false);
        BoxMoveTime = 0;
        BoxMoveStart = true;
    }

     public void CreateAdBox()
    {
        if (BoxStart == null || BoxMoveStart)
        {
            return;
        }
        SetNormalBoxActive(false);
        SetAdBoxActive(true);
        SetBoxPosion(BoxStart.position);
        BoxMoveTime = 0;
        BoxMoveStart = true;
    }

    void SetBoxPosion(Vector3 vector)
    {
        if(BoxHead)
        {
            BoxHead.position = vector;
        }
    }
    void UpdateBoxPostion()
    {
        BoxMoveTime += Time.fixedDeltaTime;
        SetBoxPosion(Vector3.Lerp(BoxStart.position,BoxEnd.position,BoxMoveTime/BoxShowTime));
        if (BoxMoveTime>=BoxShowTime)
        {
            BoxMoveStart = false;
        }
    }
    void SetRopeStateByFishState(FishState state)
    {
        if (FishingLine != null)
        {
            switch(state)
            {
                case FishState.WaitFishBite:
                    FishingLine.SetState(FishingRope.eState.UnderWater);
                break;
                case FishState.FishBite:
                    FishingLine.SetState(FishingRope.eState.HookSet);
                break;
                case FishState.Normal:
                    FishingLine.SetState(FishingRope.eState.HookSet);
                break;
                case FishState.PlayerFight:
                    FishingLine.SetState(FishingRope.eState.HookSet);
                break;
                case FishState.Jump:
                    FishingLine.SetState(FishingRope.eState.HookSet);
                break;

            }
            
        }
    }

    void SetLureActive(bool _bool)
    {
        if (LureTranform != null )
        {
            LureTranform.gameObject.SetActive(_bool);
        }
    }

    void SetNormalBoxActive(bool _bool)
    {
        AdBox?.gameObject.SetActive(_bool);
    }
    void SetAdBoxActive(bool _bool)
    {
        NormalBox?.gameObject.SetActive(_bool);
    }
    void SetRopeStateByStageEnum(AutoStageEnum state)
    {
        if (FishingLine != null)
        {
            switch(state)
            {
                case AutoStageEnum.Throw:
                    FishingLine.SetState(FishingRope.eState.Fly);
                    break;
                case AutoStageEnum.PullBack:
                    FishingLine.SetState(FishingRope.eState.Landing);
                    break;
                case AutoStageEnum.PullUp:
                    FishingLine.SetState(FishingRope.eState.Landing);
                    break;
                case AutoStageEnum.Show:
                    FishingLine.SetState(FishingRope.eState.Hide);
                    break;

            }
            
        }
    }

    void SetLurePostion(Vector3 pos)
    {   
        if (LureTranform != null)
        {
            LureTranform.position = pos;
        }
    }

    void SetRodAnimation(RodAnimationState state)
    {
        if (FishingRodAnimator != null)
        {
            switch(state){
            case RodAnimationState.Throw:
                FishingRodAnimator.Play("Throw");
                break;
            case RodAnimationState.Normal:
                FishingRodAnimator.CrossFadeInFixedTime("Idle",0.01f);
                break;
            default:
                return;
            }
        }
    }

    void SetFishAnimation(FishAnimationState state)
    {
        if (FishAnimator != null)
        {
            FishAnimator.speed = 1;
            switch(state){
            case FishAnimationState.JumpOut:
                FishAnimator.Play("FightDefault");
                break;
            case FishAnimationState.FightDefault:
                FishAnimator.CrossFadeInFixedTime("FightDefault",0.2f);
                break;
            case FishAnimationState.FightBite:
                FishAnimator.CrossFadeInFixedTime("FightBite",0.2f);
                break;
            case FishAnimationState.DamageHit:
                FishAnimator.CrossFadeInFixedTime("DamageHitStart",0.1f);
                break;
            case FishAnimationState.FightFinish:
                FishAnimator.speed = 0.7f;
                FishAnimator.CrossFadeInFixedTime("FightFinish",0.2f);
                break;
            case FishAnimationState.FightWeakly:
                FishAnimator.CrossFadeInFixedTime("FightWeakly",0.2f);
                break;
            default:
                return;
            }
        }
    }

    void HideFish()
    {   
        if (FishPrefab != null)
        {
            FishPrefab.gameObject.SetActive(false);
        }
        if (HunterSlotTf != null)
        {
            HunterSlotTf.gameObject.SetActive(false);
        }
    }
    void SetFishPostion(Vector3 pos)
    {   
        if (!Huntted && FishPrefab != null)
        {
            FishPrefab.gameObject.SetActive(true);
            FishPrefab.position = pos;
        }
         if(Huntted && null !=HunterSlotTf)
        {
            HunterSlotTf.gameObject.SetActive(true);
            HunterSlotTf.position = pos;
        }
    }

    void FishLookAtCamera(float value)
    {
        if (!Huntted && FishPrefab != null)
        {
            FishPrefab.LookAt(RodHead.position + new Vector3(-value,0,0));

        }
         if(Huntted && null !=HunterSlotTf)
        {
            HunterSlotTf.LookAt(RodHead.position + new Vector3(-value,0,0));

        }
    }
    void SetRodPower(float weight)
    {
        weight = weight > 1 ? 1 : weight;
        if (weight <= 0)
        {
            PlayAudio(0);
        }
        else
        {
            if (weight > 0.75)
            {
                PlayAudio(2);
            }
            else
            {
                PlayAudio(1);
            }
        }
        
        if (weight > 0.75)
        {
            weight = Random.Range( weight - 0.08f,weight +0.05f);
            PlayAudio(2);
        }
        if (FishingRodAnimator != null)
            FishingRodAnimator.SetLayerWeight(1,weight);
    }
    void SetRodRotation(Vector3 vector3)
    {
        if (FishingRodRoot != null)
        {
            FishingRodRoot.localEulerAngles = vector3;
        }
    }

    void SetRodHeadRotation(Vector3 vector3)
    {
        if (RodHead != null)
        {
            RodHead.localEulerAngles = vector3;
        }
    }

    void PlayEffect(EffectState state,Vector3 pos)
    {
        GameObject obj = null;
        switch(state)
        {
            case EffectState.LureEnterWater:
                obj = LureEnterWaterEffect;
                break;
            case EffectState.EnterWater:
                obj = EnterWaterEffect;
                break;
            case EffectState.EnterWaterBig:
                obj = EnterWaterEffect;
                break;
            case EffectState.JumpOut:
                obj = JumpOutEffect;
                break;
            case EffectState.JumpOutBig:
                obj = EnterWaterEffect;
                break;
            case EffectState.Crit:
                obj = CritEffect;
                break;
            case EffectState.Move:
                obj = FishMoveEffect;
                break;
            case EffectState.PullUp:
                obj = SkillEffect;
                break;
            case EffectState.Stay:
                obj = WaitEffect;
                break;
            default:
                return;
        }
        
        if(obj != null)
        {
            obj.transform.position = pos;
            if(obj.activeSelf && EffectState.Move != state)
            {
                obj.SetActive(false);
                obj.SetActive(true);
            }
            else
            {
                obj.SetActive(true);
            }
        }
    }
    
    void HideEffect(EffectState state)
    {
         GameObject obj = null;
        switch(state)
        {
            case EffectState.LureEnterWater:
                obj = LureEnterWaterEffect;
                break;
            case EffectState.EnterWater:
                obj = EnterWaterEffect;
                break;
            case EffectState.EnterWaterBig:
                obj = EnterWaterEffect;
                break;
            case EffectState.JumpOut:
                obj = JumpOutEffect;
                break;
            case EffectState.JumpOutBig:
                obj = EnterWaterEffect;
                break;
            case EffectState.Crit:
                obj = CritEffect;
                break;
            case EffectState.Move:
                obj = FishMoveEffect;
                break;
            case EffectState.PullUp:
                obj = SkillEffect;
                break;
            case EffectState.Stay:
                obj = WaitEffect;
                break;
            default:
                return;
        }
        
        if(obj != null)
        {
            obj.SetActive(false);
        }
    }
    void DoTrow()
    {
        SetRodAnimation(RodAnimationState.Throw);
        SetRodPower(0);
        CurrentState = AutoStageEnum.Throw;
        CurrentPlayState = PlayStageEnum.Throw;
        CurrentBoxState = BoxStageEnum.Throw;
        CurrentTime = 0;
        RopeThrowed = false;
        RopeFollowDown = false;
        FishCallUI(UIStateEnum.Throw);
    }
    void DoTrowRope()
    {
        // SetRodAnimation(RodAnimationState.Normal);
        SetLurePostion(LineStartTransform.position);
        SetRopeStateByStageEnum(AutoStageEnum.Throw);
        RopeThrowed = true;
        //addforce
        SetLureActive(true);
        if ( LureRigidbody != null)
        {
            LureRigidbody.velocity = Vector3.zero;
			LureTranform.rotation = Quaternion.Euler(0, 0, 0f);
			LureRigidbody.freezeRotation = true;
            LureRigidbody.useGravity = true;
			LureRigidbody.AddForce(CastForce);
        }
        
    }

    void DoTrowRopeToBox()
    {
        startPos = LineStartTransform.position;
        endPos = BoxHead.position;
        distance = Vector3.Distance(startPos, endPos);
        middlePos = 0.5f * (startPos + endPos) + new Vector3(0, distance, 0) * 0.2f;
        SetLurePostion(LineStartTransform.position);
        SetRopeStateByStageEnum(AutoStageEnum.Throw);
        flyTime = 0;
        RopeThrowed = true;
        SetLureActive(true);
    }

    void TrowToBoxUpdate()
    {
        if ( LureTranform == null)
        {
            return;
        }
        
        
        if ( !RopeThrowed)
        {
            CurrentTime += Time.fixedDeltaTime;
            if (CurrentTime >= ShowLineTime)
            {
                DoTrowRopeToBox();
            }
        }
        else
        {
            flyTime += Time.fixedDeltaTime;
            SetBezierPostionAsScale(LureTranform,flyTime/flyMaxTime);
            if (flyTime >= flyMaxTime)
            {
                DoPullBoxBack();
            }
        }

    }
    void SetBezierPostionAsScale(Transform tf, float scale)
    {
        if (scale > 1)
        {
            scale = 1;
        }
        if (scale < 0)
        {
            scale = 0;
        }
        resultPos.x =
            scale * scale * (endPos.x - 2 * middlePos.x + startPos.x) + startPos.x +
            2 * scale * (middlePos.x - startPos.x);
        resultPos.y =
            scale * scale * (endPos.y - 2 * middlePos.y + startPos.y) + startPos.y +
            2 * scale * (middlePos.y - startPos.y);
        resultPos.z =
            scale * scale * (endPos.z - 2 * middlePos.z + startPos.z) + startPos.z +
            2 * scale * (middlePos.z - startPos.z);
        tf.position = resultPos;
    }

    void FollowDown()
    {
        RopeFollowDown = true;
        LureRigidbody.velocity = Vector3.zero;
		LureRigidbody.useGravity = false;
    }
    void TrowCheck()
    {
        if ( LureTranform == null)
        {
            return;
        }
        
        
        if ( !RopeThrowed)
        {
            CurrentTime += Time.fixedDeltaTime;
            if (CurrentTime >= ShowLineTime)
            {
                DoTrowRope();
            }
            else
            {
                SetLurePostion(LineStartTransform.position);
            }
        }
        if ( LureTranform.position.y <= WaterY)
        {
            PlayEffect(EffectState.LureEnterWater,LureTranform.position);
            FollowDown();
            if (PlayMode == PlayModeEnum.PlayerControl)
            {
                StartSimulateFight();
            }
            else
            {
                StartSimulate();
            }
            return;
        }

    }

    ShowData NewShowData(int Index,float Time,FishState State = FishState.Normal,float FinalForce = 0f,float AddForce = 0.1f, float InitSpeed = 6.5f)
    {
        ShowData Data = new  ShowData();
        Data.Index = Index;
        Data.State = State;
        Data.Time = Time;
        Data.AddForceSec = AddForce;
        Data.FinalForce = FinalForce;
        Data.InitSpeed = InitSpeed;
        return Data;
    }
    public void SetShowList()
    {
        ShowList.Clear();
        ShowList.Add(NewShowData(1,5f,FishState.WaitFishBite,0f,1f));
        ShowList.Add(NewShowData(2,0.1f,FishState.FishBite,0.3f,1f));
        ShowList.Add(NewShowData(3,1f,FishState.Normal,0.3f,1f));
        ShowList.Add(NewShowData(4,4f,FishState.Normal,0.3f,-1f));
        ShowList.Add(NewShowData(5,2f,FishState.Normal,0.4f,1f));
        ShowList.Add(NewShowData(6,4f,FishState.Normal,0.3f,-1f));
        ShowList.Add(NewShowData(7,2f,FishState.Normal,0f,-0.2f));
        ShowList.Add(NewShowData(8,3f,FishState.Normal,0.4f,1));
        ShowList.Add(NewShowData(9,1f,FishState.Normal,0.3f,-1));
        ShowList.Add(NewShowData(10,2f,FishState.Normal,0.8f,1f));
        ShowList.Add(NewShowData(11,1f,FishState.Normal,0.5f,-2f));
        ShowList.Add(NewShowData(12,5f,FishState.Normal,0.7f,2));
        ShowList.Add(NewShowData(13,0f,FishState.Jump,0f,-0.5f));
        ShowList.Add(NewShowData(14,4f,FishState.Normal,0.6f,1));
        ShowList.Add(NewShowData(15,2f,FishState.Normal,1,1f));
        ShowList.Add(NewShowData(16,2f,FishState.Normal,0.5f,-1));
        ShowList.Add(NewShowData(17,1f,FishState.Normal,0.8f,1));
        ShowList.Add(NewShowData(18,1f,FishState.Normal,0.6f,-2));
        ShowList.Add(NewShowData(19,1f,FishState.Normal,0.4f,-1));
        ShowList.Add(NewShowData(20,1f,FishState.Normal,0.8f,1));
        ShowList.Add(NewShowData(21,1f,FishState.Normal,0.5f,-1));
        ShowList.Add(NewShowData(22,1f,FishState.Normal,0.4f,-1));
        ShowList.Add(NewShowData(23,1f,FishState.Normal,0.8f,1));
    }

    public void SetAutoSimulateData(List<ShowData> datas)
    { 
        foreach (ShowData data in datas)
        {
            ShowList.Clear();
            ShowList.Add(data);
        }
    }
    public void StartSimulate()
    {

        //伪装数据
        SetShowList();
        CurrentState = AutoStageEnum.Simulate;
        MaxIndex = ShowList.Count;
        CurrentVector = StartMoveTransform.position;
        CurrentShowData = new ShowData();
        if (PlayMode == PlayModeEnum.Auto && AutoFishCallBack != null)
        {
            AutoFishCallBack();
        }
        DoNextSimulate();
        RodForce = 0;
    }

    void DoNextSimulate()
    {
        if (CurrentShowData.Index >= MaxIndex)
        {
            DoPullBack();
            return;
        }
        CurrentTime = 0;
        CurrentShowData = ShowList[CurrentShowData.Index];
        SetRopeStateByFishState(CurrentShowData.State);
        switch(CurrentShowData.State)
        {
            case FishState.WaitFishBite:
            SetRodAnimation(RodAnimationState.Normal);
            PlayEffect(EffectState.Stay,LureTranform.position);
            FishingLine.SetState(FishingRope.eState.Wait);
            FishCallUI(UIStateEnum.WaitFishBite);
                break;
            case FishState.FishBite:
            HideEffect(EffectState.Stay);
            SetRodAnimation(RodAnimationState.Normal);
            SetLurePostion(StartMoveTransform.position);
            FishCallUI(UIStateEnum.FishBite);
                break;
            case FishState.Normal:
            SetRodAnimation(RodAnimationState.Normal);
                break;
            case FishState.Jump:
            Jumped = false;
            SetRodAnimation(RodAnimationState.Normal);
            CurrentFishVector = LureTranform.position;
            CurrentJumpSpeed = CurrentShowData.InitSpeed;
            SetFishPostion(CurrentFishVector);
            SetFishAnimation(FishAnimationState.JumpOut);
            HideEffect(EffectState.Move);
            PlayEffect(EffectState.JumpOut,LureTranform.position);
            FishingLine.SetState(FishingRope.eState.Fly);
            PlayAudio(3011);
                break;
            default:
                return;
        }
        
    }
    void WaitFishBiteUpdate()
    { 
        
    }

    void FishBiteUpdate()
    {
        PlayEffect(EffectState.Move,LureTranform.position);
        SetLurePostion(Vector3.Lerp(StartBiteTransform.position,StartMoveTransform.position,CurrentTime/CurrentShowData.Time));
    }

    void SetRotation()
    {
        RootToLueVector = LureTranform.position - FishingRodRoot.position;
        RootToTopVector = LineStartTransform.position - FishingRodRoot.position;
        ANormalize =Vector3.Cross(RootToLueVector,RootToTopVector);
        Angle = Vector3.Angle(ANormalize,Vector3.left);
         if (RootToLueVector.x > 0)
         {
             AngleVector.x = 180 - Angle ;
         }
         else
         {
             AngleVector.x = Angle -180;
         }
        AngleVector.y = 0;
        AngleVector.z = 0;
        SetRodRotation(AngleVector);
    }
    void FishMoveUpdate()
    {
        if(StartMoveTransform == null)
        {
            return;
        }
        if (IsTurnLeft)
        {
            CurrentVector.x = CurrentVector.x + Time.fixedDeltaTime * AddOffsetForce;
            CompareNum = CurrentVector.x - StartMoveTransform.position.x;
            if (CompareNum > MaxLeftOffset)
            {
                IsTurnLeft = false;
            }  
        }
        else
        {
            CurrentVector.x = CurrentVector.x - Time.fixedDeltaTime * AddOffsetForce;
            CompareNum = CurrentVector.x - StartMoveTransform.position.x;
            if (CompareNum < (- MaxRightOffset))
                IsTurnLeft = true;
        }
        SetLurePostion(CurrentVector);
        SetRotation();
        PlayEffect(EffectState.Move,LureTranform.position);
    }
    void FishJumpUpdate()
    {
        CurrentFishVector.y = CurrentFishVector.y + CurrentJumpSpeed*Time.fixedDeltaTime - G*Time.fixedDeltaTime*Time.fixedDeltaTime/2;
        CurrentJumpSpeed -= G*Time.fixedDeltaTime;
        if (Jumped && TurnTime < 0.3f)
        {
            TurnTime += Time.fixedDeltaTime;
            SetFishRotationXY(Mathf.Lerp(0,-165,TurnTime/0.3f),Mathf.Lerp(-45,-90,TurnTime/0.3f));
        }
        if(!Jumped && CurrentJumpSpeed <= 0)
        {
            SetFishAnimation(FishAnimationState.FightDefault);
            Jumped = true;
        }
        SetFishPostion(CurrentFishVector);
        if(FishMouse != null)
        {
            SetLurePostion(FishMouse.transform.position);
        }
        if(Jumped && CurrentFishVector.y <= WaterY)
        {
            SetFishRotationXY(0,0);
            PlayEffect(EffectState.EnterWater,LureTranform.position);
            HideFish();
            DoNextSimulate();
            PlayAudio(3012);
        }
    }
    void SimulateUpdate()
    {
        CurrentTime += Time.fixedDeltaTime;
        if (CurrentShowData.Time != 0 && CurrentTime >= CurrentShowData.Time)
        {
            DoNextSimulate();
            return;
        }
         
        RodForce += Time.fixedDeltaTime*CurrentShowData.AddForceSec;
        if (CurrentShowData.AddForceSec > 0)
        {
             RodForce = RodForce >= CurrentShowData.FinalForce ? CurrentShowData.FinalForce : RodForce;
        }
        else
        {
            RodForce = RodForce <= CurrentShowData.FinalForce ? CurrentShowData.FinalForce : RodForce;
        }
        SetRodPower(RodForce);
        
        switch(CurrentShowData.State)
        {
            case FishState.WaitFishBite:
            WaitFishBiteUpdate();
                break;
            case FishState.FishBite:
            FishBiteUpdate();
                break;
            case FishState.Normal:
            FishMoveUpdate();
                break;
            case FishState.Jump:
            FishJumpUpdate();
                break;
            default:
                return;
        }
    }

    void ContinueSimulateFight()
    {
        CurrentPlayState = PlayStageEnum.SimulateFight;
        FishCallUI(UIStateEnum.Fight);
    }

    void ChangeCritChance(bool canCrit)
    {
        if(canCrit != CanCrit)
        {
            //dispatch
            if (canCrit)
            {
                FishCallUI(UIStateEnum.CriticalStrikeChance);
            }
            else
            {
                FishCallUI(UIStateEnum.InAir);
            }
            
            CanCrit = canCrit;
        }
    }

    //暴击抽打鱼表现
    void DoCrit()
    {
        LerpValue = 0;
        CritTime = 0;
        Critting = true;
        SetFishRotationXY(0,0);
        FishingLine.SetState(FishingRope.eState.HookSet);
        if (!Huntted)
        {
            SetFishAnimation(FishAnimationState.DamageHit);
        }
        else
        {
            SetHunterAnimation(FishAnimationState.DamageHit);
        }
        FishCallUI(UIStateEnum.Crit);
    }

    void CreateCritDamage()
    {   
        int damage = CurrentEventIndex <= MaxEventIndex ? EventDamages[CurrentEventIndex]:0;
        CurrentFishHP -= damage; 
        if (CritDamage != null)
        {
            CritDamage(damage);
        }
        PlayEffect(EffectState.Crit,LureTranform.position);
    }


    void SetHunterAnimation(FishAnimationState state)
    {
        if (HunterAnim != null)
        {
            switch(state){
            case FishAnimationState.JumpOut:
                HunterAnim.Play("FightDefault");
                break;
            case FishAnimationState.FightDefault:
                HunterAnim.CrossFadeInFixedTime("FightDefault",0.1f);
                break;
            case FishAnimationState.FightBite:
                HunterAnim.CrossFadeInFixedTime("FightBite",0.1f);
                break;
            case FishAnimationState.DamageHit:
                HunterAnim.CrossFadeInFixedTime("DamageHitStart",0.1f);
                break;
            case FishAnimationState.FightFinish:
                HunterAnim.CrossFadeInFixedTime("FightFinish",0.1f);
                break;
            case FishAnimationState.FightWeakly:
                HunterAnim.CrossFadeInFixedTime("FightWeakly",0.1f);
                break;
            default:
                return;
            }
        }
    }

    void DoHunterJump()
    {
        HStage = HuntStage.Jump;
        BitePrepared = false;
        flyTime = 0;
        HunterSlotTf?.gameObject.SetActive(true);
        FishCallUI(UIStateEnum.HunterJump);
        SetHunterAnimation(FishAnimationState.JumpOut);
        SetHunterRotation(0);
    }
    void DoHunterBite()
    {
        flyTime = 0;
        HStage = HuntStage.Bite;
        FishPrefab.SetParent(HunterMouseTf);
        FishPrefab.localPosition = Vector3.zero;
        FishingLine.SetState(FishingRope.eState.Hide);
        // SetHunterAnimation(FishAnimationState.FightBite);
    }
    void DoHunterFollow()
    {
        HStage = HuntStage.Follow;
        CurrentJumpSpeed = 0;
        
        CurrentFishVector = HunterSlotTf.position;
        // SetHunterAnimation(FishAnimationState.FightDefault);
    }
    void GobackToNormalFish()
    {
        Huntted = true;
        HideFish();
        CurrentEventIndex += 1;
        ContinueSimulateFight();
    }
    void HunterJumpUpdate()
    {
        
        flyTime += Time.fixedDeltaTime;
        HuntTimeScale = flyTime/HuntJumpTime;
        SetBezierPostionAsScale(HunterSlotTf,HuntTimeScale);
        // HunterSlotTf.LookAt(endPos);
        if (!HuntJumpEffectPlayed && HunterSlotTf.position.x >= WaterY)
        {
            HuntJumpEffectPlayed = true;
            PlayEffect(EffectState.JumpOutBig,HunterSlotTf.position);
        }
        if(!BitePrepared && flyTime >= BitePrepareTime)
        {
            SetHunterAnimation(FishAnimationState.FightBite);
            BitePrepared = true;
        }
        if(flyTime >= HuntJumpTime)
        {
            DoHunterBite();
        }
    }
    void HunterBiteUpdate()
    {   
        flyTime += Time.fixedDeltaTime;
        SetLurePostion(FishMouse.transform.position);
        if (flyTime > HunterBiteTime)
        {
            DoHunterFollow();
        }
    }
    void SetHunterPostion(Vector3 pos)
    {
        if(null !=HunterSlotTf)
        {
            HunterSlotTf.position = pos;
        }
    }

    void SetHunterRotation(float rotateY)
    {
        if(null !=HunterSlotTf)
        {
            var angle = HunterSlotTf.eulerAngles;
            angle.y = rotateY;
            HunterSlotTf.eulerAngles = angle;
        }
    }
    void HunterFollowUpdate()
    {
        CurrentFishVector.y = CurrentFishVector.y + CurrentJumpSpeed*Time.fixedDeltaTime - G*Time.fixedDeltaTime*Time.fixedDeltaTime/2;
        SetHunterPostion(CurrentFishVector);
        CurrentJumpSpeed -= G*Time.fixedDeltaTime;
        SetLurePostion(FishMouse.transform.position);
        if (!HuntEnterWaterEffectPlayed && HunterSlotTf.position.y <= WaterY)
        {
           HuntEnterWaterEffectPlayed = true;
           PlayEffect(EffectState.EnterWaterBig,HunterSlotTf.position);
        }
        // if (HunterSlotTf.position.y <= startPos.y)
        // {
        //     GobackToNormalFish();
        // }
         if (HunterSlotTf.position.y <= WaterY)
        {
            PlayEffect(EffectState.EnterWaterBig,HunterSlotTf.position);
            GobackToNormalFish();
        }
    }
    void HunttingUpdate()
    {
        if (HStage == HuntStage.None)
        {
            DoHunterJump();
        }
        if (HStage == HuntStage.Jump)
        {
            HunterJumpUpdate();
        }
        if (HStage == HuntStage.Bite)
        {
            HunterBiteUpdate();
        }
        if (HStage == HuntStage.Follow)
        {
            HunterFollowUpdate();
        }
    }

    void SetFishRotationXY(float x,float y)
    {
        if (!Huntted && FishPrefab != null)
        {
            FishPrefab.transform.rotation = Quaternion.Euler(x,y,0f)  ;
        }
         if(Huntted && null !=HunterSlotTf)
        {
            HunterTf.transform.rotation = Quaternion.Euler(x,y,0f)  ;
        }
    }

 
    // 需要调整
    void FightJumpUpdate()
    {
        // A = Mathf.Lerp(G,1,(PlayModeJumpSpeed - CurrentJumpSpeed)/PlayModeJumpSpeed);
        if (!Critting && (!Huntting || Huntted))
        {
            CurrentFishVector.y = CurrentFishVector.y + CurrentJumpSpeed*Time.fixedDeltaTime - G*Time.fixedDeltaTime*Time.fixedDeltaTime/2;
            CurrentJumpSpeed -= G*Time.fixedDeltaTime;
        }
        if (Jumped && !AngleChanged && TurnTime < TurnNeedTime)
        {
            TurnTime += Time.fixedDeltaTime;
            SetFishRotationXY(Mathf.Lerp(0,-100,TurnTime/TurnNeedTime),Mathf.Lerp(-45,-76,TurnTime/TurnNeedTime));
        }
        if (Jumped && AngleChanged )
        {
            SetFishRotationXY(0,-45);
        }

        if(!Jumped && CurrentJumpSpeed <= 0)
        {
            if (IsHunt)
            {
                InitHunt();
            }
            {
                ChangeCritChance(false);
            }
            CurrentJumpSpeed = - 5f;
            Jumped = true;
        }
        if (!Huntted && Huntting)
        {
            HunttingUpdate();
            return;
        }

        if (CanCrit && InputCrit)
        {   
            DoCrit();
            if (!IsHunt)
            {
                ChangeCritChance(false);
            }
        }

        if (Critting)
        {
            if (!AngleChanged)
            {
                CritTime += Time.fixedDeltaTime;
                LerpValue = CritTime*7;
                RodAngle = Mathf.Lerp(RodAngle,CritChangeAngle,LerpValue);
                RodForce = Mathf.Lerp(RodForce,1,LerpValue);
                if (RodAngle <= CritChangeAngle)
                {
                    CreateCritDamage();
                    CritTime = 0;
                    RodAngle = CritChangeAngle;
                    CurrentJumpSpeed = 0;
                    AngleChanged = true;
                }
            }
            else
            {
                CritTime += Time.fixedDeltaTime;
                LerpValue = CritTime*2f;
                RodAngle = Mathf.Lerp(CritChangeAngle,0,LerpValue);
                RodForce = Mathf.Lerp(RodForce,0,LerpValue);
                if (RodAngle >= 0)
                {
                    RodAngle = 0;
                    Critting = false;
                    HideEffect(EffectState.Crit);
                    // SetFishAnimation(FishAnimationState.FightDefault);
                }
            }
            CritAngleVector.x = 0;
            CritAngleVector.y = FishingRodRoot.localEulerAngles.y;
            CritAngleVector.z = RodAngle;
            SetRodHeadRotation(CritAngleVector);
        }
        else
        {
            RodForce -= FightJumpAddForce*Time.fixedDeltaTime;
            if(RodForce < 0)
            {
                RodForce = 0;
            }
        }
        SetFishPostion(CurrentFishVector);
        SetLurePostion(FishMouse.transform.position);
        SetRodPower(RodForce);
        if(Jumped && CurrentFishVector.y <= WaterY)
        {
            PlayEffect(EffectState.EnterWater,LureTranform.position);
            SetFishRotationXY(0,-10);
            PlayAudio(3012);
            HideFish();
            CurrentEventIndex += 1;
            ContinueSimulateFight();
        }
    }

    void UpdatePlayerForce()
    {
        if (Touching)
        {
            RodForce = RodForce + Time.fixedDeltaTime*PlayerAddForce;
        }
        else
        {
            RodForce = RodForce - Time.fixedDeltaTime*BackForce; 
        }
        RodForce = RodForce >= 1 ? 1 : RodForce;
        RodForce = RodForce <= 0 ? 0 : RodForce;
        SetRodPower(RodForce);
    }

    void UpdateShowDataForce()
    {
        RodForce += Time.fixedDeltaTime*CurrentShowData.AddForceSec;
        if (CurrentShowData.AddForceSec > 0)
        {
             RodForce = RodForce >= CurrentShowData.FinalForce ? CurrentShowData.FinalForce : RodForce;
        }
        else
        {
            RodForce = RodForce <= CurrentShowData.FinalForce ? CurrentShowData.FinalForce : RodForce;
        }
        SetRodPower(RodForce);
    }

    void DoJump()
    {
        A = G;
        Jumped = false;
        InputCrit = false;
        Critting = false;
        Touching = false;
        AngleChanged = false;
        TurnTime = 0;
        CurrentFishVector = LureTranform.position;
        CurrentJumpSpeed = PlayModeJumpSpeed;
        CurrentPlayState = PlayStageEnum.Jump;
        FishingLine.SetState(FishingRope.eState.Fly);
        PlayAudio(3011);
        SetFishRotationXY(0,-45);
        if (!IsHunt)
        {
            ChangeCritChance(true);
        }
        else
        {
            FishCallUI(UIStateEnum.HuntStart);
        }
        SetFishPostion(CurrentFishVector);
        if(!Huntted)
        {
            SetFishAnimation(FishAnimationState.JumpOut);
        }
        else
        {
            SetHunterAnimation(FishAnimationState.JumpOut);
        }
        HideEffect(EffectState.Move);
        PlayEffect(EffectState.JumpOut,LureTranform.position);
    }
    void UpdateFishHp()
    {
        if(Touching)
        {
            CurrentFishHP = CurrentFishHP - NormalDamage*Time.fixedDeltaTime;
        }
        
        if (UpdateUIHp != null)
        {
            HpUpdateTime += Time.fixedDeltaTime;
            if (HpUpdateTime >= HpHitTime)
            {
                HpUpdateTime = 0;
                UpdateUIHp(CurrentFishHP);
            }
            
        }
        if (CurrentEventIndex <= MaxEventIndex && CurrentFishHP <= EventHpValues[CurrentEventIndex])
        {
            IsHunt = EventHpTypes[CurrentEventIndex] == (int)EventType.Hunt;
            DoJump();
            
        }
        if (CurrentFishHP <= 0)
        {
            DoPullBack();
        }
    }
    void SimulateFightUpdate()
    {
        CurrentTime += Time.fixedDeltaTime;
        if ( CurrentShowData.State != FishState.PlayerFight && CurrentShowData.Time != 0 && CurrentTime >= CurrentShowData.Time)
        {
            DoNextSimulateFight();
            return;
        }
        switch(CurrentShowData.State)
        {
            case FishState.WaitFishBite:
            UpdateShowDataForce();
            WaitFishBiteUpdate();
                break;
            case FishState.FishBite:
            UpdateShowDataForce();
            FishBiteUpdate();
                break;
            case FishState.PlayerFight:
            UpdatePlayerForce();
            UpdateFishHp();
            FishMoveUpdate();
                break;
            default:
                return;
        }
    }
    void DoNextSimulateFight()
    {
        if (CurrentShowData.Index >= MaxIndex)
        {
            DoPullBack();
            return;
        }
        CurrentTime = 0;
        CurrentShowData = ShowList[CurrentShowData.Index];
        SetRopeStateByFishState(CurrentShowData.State);
        switch(CurrentShowData.State)
        {
            case FishState.WaitFishBite:
            SetRodAnimation(RodAnimationState.Normal);
            PlayEffect(EffectState.Stay,LureTranform.position);
            FishCallUI(UIStateEnum.WaitFishBite);
            FishingLine.SetState(FishingRope.eState.Wait);
                break;
            case FishState.FishBite:
            HideEffect(EffectState.Stay);
            SetRodAnimation(RodAnimationState.Normal);
            SetLurePostion(StartMoveTransform.position);
            FishCallUI(UIStateEnum.FishBite);
                break;
            case FishState.PlayerFight:
            FishCallUI(UIStateEnum.Fight);
            HpUpdateTime = 0;
            SetRodAnimation(RodAnimationState.Normal);
                break;
            default:
                return;
        }
        
    }
    void StartSimulateFight()
    {
        ShowList.Clear();
        ShowList.Add(NewShowData(1,3f,FishState.WaitFishBite,0f,1f));
        ShowList.Add(NewShowData(2,0.1f,FishState.FishBite,0.3f,1f));
        ShowList.Add(NewShowData(3,0,FishState.PlayerFight));
        EventHpValues.Clear();
        MaxEventIndex = Mathf.Min(EventHpPers.Count,EventHpTypes.Count);
        MaxEventIndex = Mathf.Min(EventDamages.Count,MaxEventIndex);
        MaxEventIndex = MaxEventIndex -1;
        foreach (float value in EventHpPers)
        {
            EventHpValues.Add(value*InitFishHP);
        }
        
        CurrentPlayState = PlayStageEnum.SimulateFight;
        MaxIndex = ShowList.Count;
        CurrentVector = StartMoveTransform.position;
        CurrentShowData = new ShowData();
        RodForce = 0;
        CurrentFishHP = InitFishHP;
        CurrentEventIndex = 0;
        Huntted = false;
        CanCrit = false;
        DoNextSimulateFight();
    }
    void DoPullBack()
    {
        CurrentTime = 0;
        CurrentState = AutoStageEnum.PullBack;
        CurrentPlayState = PlayStageEnum.PullBack;
        FishingLine.SetState(FishingRope.eState.HookSet);
        HideFish();
        FishCallUI(UIStateEnum.PullBack);
    }
    void PullBackUpdate()
    {
        CurrentTime += Time.fixedDeltaTime;
        SetLurePostion(Vector3.Lerp(CurrentVector,PullUpTransform.position,CurrentTime/PullBackTime));
        SetRotation();
        // RodForce += Time.fixedDeltaTime*0.01f;
        SetRodPower(1);
        PlayEffect(EffectState.Move,LureTranform.position);
        if (CurrentTime >= PullBackTime)
        {
            HideEffect(EffectState.Move);
            DoPullUp();
        }
    }

    void DoPullBoxBack()
    {
        CurrentTime = 0;
        CurrentVector = BoxHead.position;
        CurrentBoxState = BoxStageEnum.PullBack;
        FishCallUI(UIStateEnum.PullBack);
    }
    void PullBoxBackUpdate()
    {
        CurrentTime += Time.fixedDeltaTime;
        SetLurePostion(Vector3.Lerp(CurrentVector,PullUpTransform.position,CurrentTime/PullBackTime));
        SetBoxPosion(Vector3.Lerp(CurrentVector,PullUpTransform.position,CurrentTime/PullBackTime));

        SetRodPower(CurrentTime*2/PullBackTime);
        PlayEffect(EffectState.Move,LureTranform.position);
        if (CurrentTime >= PullBackTime)
        {
            HideEffect(EffectState.Move);
            PlayMode = PlayModeEnum.None;
            SetNormalBoxActive(false);
            SetAdBoxActive(false);
            SetRopeStateByStageEnum(AutoStageEnum.Show);
            FishingRod.gameObject.SetActive(false);
            FishCallUI(UIStateEnum.Show);
        }
    }

    void DoPullUp()
    {
        CurrentTime = 0;
        CurrentState = AutoStageEnum.PullUp;
        CurrentPlayState = PlayStageEnum.PullUp;
        CurrentVector = PullUpTransform.position;
        CurrentJumpSpeed = InitPullSpeed;
        SetFishPostion(CurrentVector);
        if(!Huntted)
        {
            SetFishAnimation(FishAnimationState.FightFinish);
        }
        else
        {
            SetHunterAnimation(FishAnimationState.FightFinish);
        }
        FishingRod.gameObject.SetActive(false);
        SetRopeStateByStageEnum(AutoStageEnum.Show);
        PlayEffect(EffectState.JumpOut,LureTranform.position);
        SetLureActive(false);
        FishCallUI(UIStateEnum.PullUp);
    }
    void PullUpUpdate()
    {
        CurrentVector.y = CurrentVector.y + CurrentJumpSpeed*Time.fixedDeltaTime*PullTimeScale - G*Time.fixedDeltaTime*PullTimeScale*Time.fixedDeltaTime*PullTimeScale/2;
        CurrentJumpSpeed -= G*Time.fixedDeltaTime*PullTimeScale;
        EffectTimeNum += Time.fixedDeltaTime*PullTimeScale;
        if(EffectTimeNum >= PullTimeScale*1)
        {
            EffectTimeNum = 0;
            PlayEffect(EffectState.PullUp,CurrentVector);
        }
        SetFishPostion(CurrentVector);
        SetLurePostion(CurrentVector);
        FishLookAtCamera(CurrentVector.y);
        
        if (CurrentJumpSpeed <= 0)
        {
            DoShowFish();
        }
    }
    void DoShowFish()
    {
        CurrentTime = 0;
        CurrentState = AutoStageEnum.Show;
        CurrentPlayState = PlayStageEnum.Show;
        SetFishAnimation(FishAnimationState.FightWeakly);
        FishCallUI(UIStateEnum.ShowGold);
    }

    void ShowFishUpdate()
    {
        CurrentTime += Time.fixedDeltaTime;
        if (CurrentTime >= FishShowTime)
        {
            if(PlayMode != PlayModeEnum.Auto)
            {
                //分发事件钓鱼成功
                PlayMode = PlayModeEnum.None;
                FishCallUI(UIStateEnum.Show);
            }
            CurrentState = AutoStageEnum.None;
        }
    }

    void HideAllEffect()
    {
        HideEffect(EffectState.Move);
        HideEffect(EffectState.PullUp);
    }
    void InitAll()
    {
        HideFish();
        HideAllEffect();
        SetRodRotation(Vector3.zero);
        SetRodHeadRotation(Vector3.zero);
        FishingLine.SetState(FishingRope.eState.Hide);
        SetLurePostion(LineStartTransform.position);
        if(Huntted)
        {
            ClearHunterInstance();
        }
        RodForce = 0;
        FishingRod.gameObject.SetActive(true);
    }


    void PlayUpdate()
    {
        if (CurrentPlayState == PlayStageEnum.Throw)
        {
            TrowCheck();
        }
        if (CurrentPlayState == PlayStageEnum.SimulateFight)
        {
            SimulateFightUpdate();
        }
        if (CurrentPlayState == PlayStageEnum.Jump)
        {
            FightJumpUpdate();
        }
        if (CurrentPlayState == PlayStageEnum.PullBack)
        {
            PullBackUpdate();
        }
        if (CurrentPlayState == PlayStageEnum.PullUp)
        {
            PullUpUpdate();
        }
        if (CurrentPlayState == PlayStageEnum.Show)
        {
            ShowFishUpdate();
        }
    }

    void BoxUpdate()
    {
        if (CurrentBoxState == BoxStageEnum.Throw)
        {
            TrowToBoxUpdate();
        }
        if (CurrentBoxState == BoxStageEnum.PullBack)
        {
            PullBoxBackUpdate();
        }
    }

    // Update is called once per frame
     void FixedUpdate()
    {

        if (BoxMoveStart)
        {
            UpdateBoxPostion();
        }
        if (PlayMode == PlayModeEnum.None)
        {
            return;
        }
        if (PlayMode == PlayModeEnum.PlayerControl)
        {
            PlayUpdate();
            return;
        }
        if (PlayMode == PlayModeEnum.Box)
        {
            BoxUpdate();
            return;
        }

        if (CurrentState == AutoStageEnum.None)
        {
            InitAll();
            DoTrow();
        }
        if (CurrentState == AutoStageEnum.Throw)
        {
            TrowCheck();
        }
        if (CurrentState == AutoStageEnum.Simulate)
        {
            SimulateUpdate();
        }
        if (CurrentState == AutoStageEnum.PullBack)
        {
            PullBackUpdate();
        }
        if (CurrentState == AutoStageEnum.PullUp)
        {
            PullUpUpdate();
        }
        if (CurrentState == AutoStageEnum.Show)
        {
            ShowFishUpdate();
        }
    }
}
