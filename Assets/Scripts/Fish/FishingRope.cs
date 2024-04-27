
// FishingRope
using System.Collections.Generic;
using UnityEngine;
[DisallowMultipleComponent]
public class FishingRope : MonoBehaviour
{
	public enum eState
	{
		None = -1,
		Casting,
		Fly,
		Dive,
		UnderWater,
		HookSet,
		Landing,
		Cut,
		Fail,
		DramaCatch,
		Success,
		Hide,
		Wait,
		Max
	}

	public const float DFT_RATIO_HALF_LINK = 0.55f;

	public const string PATH_HAND_LINE_ROOT = "Rod00/Rod01/Rod02/Rod03/Rod04/Rod05/LineRoot0";

	private const float SAFE_COLOR_RATIO = 0.5f;

	public static FishingRope Inst;

	[HideInInspector]
	public Transform m_Transform;

	private LineRenderer m_LineRenderer;

	private List<Transform> m_listTrsHitCollider;

	[HideInInspector]
	public eState m_eState = eState.None;

	public int MAX_LINK = 40;

	public int HALF_LINK;

	private int LINK_IDX_TAIL;

	private float LINK_GAP_RATIO;

	public Transform m_trsHead;

	public Transform m_trsTail;

	private Vector3[] m_vtAryLinkPos;

	private bool m_bIsCheckStraightLine;

	[HideInInspector]
	public bool m_bIsUnderWaterReeling;

	public Color m_colorStart;

	public Color m_colorFail;

	private Color m_colorCur;

	public Color[] m_colorAryWarning = (Color[])(object)new Color[3];

	private int m_nIdxWarning;

	private void Awake()
	{
		Inst = this;
		m_Transform = ((Component)this).transform;
		SetNoneCurveRatio();
		LINK_IDX_TAIL = MAX_LINK - 1;
		LINK_GAP_RATIO = 1f / (float)MAX_LINK;
		m_LineRenderer = ((Component)this).GetComponent<LineRenderer>();
		m_LineRenderer.positionCount = MAX_LINK;
		m_vtAryLinkPos = (Vector3[])(object)new Vector3[MAX_LINK];
		m_listTrsHitCollider = new List<Transform>();
		for (int i = 0; i < MAX_LINK; i++)
		{
			ref Vector3 reference = ref m_vtAryLinkPos[i];
			reference = Vector3.zero;
			GameObject val = GameObject.CreatePrimitive((PrimitiveType)0);
			val.transform.SetParent(((Component)this).transform);
			val.transform.position = m_vtAryLinkPos[i];
			val.transform.localScale = new Vector3(0.01f, 0.01f, 0.01f);
			val.GetComponent<SphereCollider>().radius = 0.01f;
            val.GetComponent<Renderer>().enabled = false;
			// val.get_renderer().set_enabled(false);
			((Collider)val.GetComponent<SphereCollider>()).enabled = false;
			m_listTrsHitCollider.Add(val.transform);
		}
	}

	private void Update()
	{

		// if (csTimeScaleMng.Inst.timeScale(csTimeLayer.eTimeLayerType.Default) == 0f && m_eState != eState.UnderWater && m_eState != eState.HookSet)
		// {
		// 	return;
		// }
		if (m_bIsCheckStraightLine)
		{
			ResetLink();
		}
		else if (!((Object)(object)m_trsHead == (Object)null) && !((Object)(object)m_trsTail == (Object)null))
		{
			Vector3 position = m_trsHead.position;
			Vector3 position2 = m_trsTail.position;
			m_vtAryLinkPos[0] = position;
			m_vtAryLinkPos[LINK_IDX_TAIL] = position2;
			bool flag = true;
			switch (m_eState){
			case eState.Casting:
				SetNoneCurveRatio(0.3f);
				SetCurve_Casting(position, position2);
				break;
			case eState.Fly:
				SetCurve_Fly(position, position2);
				break;
			case eState.Dive:
				SetCurve_Dive(position, position2);
				break;
			case eState.HookSet:
				SetCurve_Casting(position, position2);
				break;
			case eState.Landing:
				SetNoneCurveRatio();
				SetCurve_Landing(position, position2);
				CheckColor();
				break;
			case eState.Cut:
				SetCurve_Fly(position, position2);
				CheckColor();
				break;
			case eState.Wait:
				// SetCurve_Fly(position, position2);
				SetCurve_Wait(position, position2);
				CheckColor();
				break;
			case eState.DramaCatch:
			case eState.Success:
				SetCurve_Casting(position, position2);
				break;
			}
			if (flag)
			{
				ResetLinRenderPos();
			}
		}
	}

	public void SetState(eState _eState)
	{
		switch (_eState)
		{
		case eState.Casting:
			SetLineWidth(0.002f, 0.002f);
			break;
		case eState.Fly:
			SetLineWidth(0.0001f, 0.008f);
			break;
		case eState.Landing:
			m_bIsUnderWaterReeling = false;
			SetLineWidth(0.001f, 0.004f);
			m_nIdxWarning = 0;
			break;
		case eState.DramaCatch:
			SetLineWidth(0.002f, 0.002f);
			break;
		case eState.Success:
			SetLineWidth(0.002f, 0.002f);
			break;
		case eState.Hide:
			SetLineWidth(0f, 0f);
			break;
		}
		m_eState = _eState;
		ResetLink(m_eState != eState.Landing && m_eState != eState.UnderWater);
		SetColor(m_colorStart);
		SetBallsEnabled(m_eState == eState.UnderWater);
	}

	public void SetHeadTail(Transform _trsHead, Transform _trsTail)
	{
		if ((Object)(object)_trsHead != (Object)null)
		{
			m_trsHead = _trsHead;
		}
		if ((Object)(object)_trsTail != (Object)null)
		{
			m_trsTail = _trsTail;
		}
	}

	public void SetLineWidth(float _fStartWidth, float _fEndWidth)
	{
		m_LineRenderer.startWidth = _fStartWidth;
        m_LineRenderer.endWidth = _fEndWidth;
	}

	private void SetBallsEnabled(bool _bIsEnabled)
	{
		foreach (Transform item in m_listTrsHitCollider)
		{
			((Collider)((Component)item).GetComponent<SphereCollider>()).enabled = _bIsEnabled;
		}
	}

	public void ResetLink(bool _bIsCheckStraightLine = false)
	{
		if (m_trsHead == null || m_trsTail == null)
		{
			return;
		}
		Vector3 position = m_trsHead.position;
		Vector3 position2 = m_trsTail.position;
		m_vtAryLinkPos[0] = position;
		m_vtAryLinkPos[LINK_IDX_TAIL] = position2;
		for (int i = 1; i < LINK_IDX_TAIL; i++)
		{
			ref Vector3 reference = ref m_vtAryLinkPos[i];
			reference = Vector3.Lerp(position, position2, (float)i * LINK_GAP_RATIO);
		}
		ResetLinRenderPos();
		m_bIsCheckStraightLine = _bIsCheckStraightLine;
	}

	private void ResetLinRenderPos()
	{
		for (int i = 0; i < MAX_LINK; i++)
		{
			m_LineRenderer.SetPosition(i, m_vtAryLinkPos[i]);
		}
	}

	private void SetCurve_Casting(Vector3 _vtHead, Vector3 _vtTail)
	{
		for (int i = 1; i < LINK_IDX_TAIL; i++)
		{
			ref Vector3 reference = ref m_vtAryLinkPos[i];
			reference = Vector3.Lerp(_vtHead, _vtTail, (float)i * LINK_GAP_RATIO);
		}
	}
 
	private void SetCurve_Fly(Vector3 _vtHead, Vector3 _vtTail)
	{
		for (int i = 1; i < LINK_IDX_TAIL; i++)
		{
			float num = (float)i * LINK_GAP_RATIO;
			Vector3 val = Vector3.Lerp(m_vtAryLinkPos[i], _vtTail, num);
			Vector3 val2 = m_vtAryLinkPos[i - 1];
			Vector3 val3 = m_vtAryLinkPos[i + 1];
			Vector3 val4 = Vector3.Lerp(val2, val3, num);
			ref Vector3 reference = ref m_vtAryLinkPos[i];
			reference = Vector3.Lerp(val4, val, Time.deltaTime);
		}
	}

	Vector3 GetBezierV3(Vector3 startPos, Vector3 middlePos,Vector3 endPos,float scale)
	{
		Vector3 resultPos = new Vector3();
		 resultPos.x =
            scale * scale * (endPos.x - 2 * middlePos.x + startPos.x) + startPos.x +
            2 * scale * (middlePos.x - startPos.x);
        resultPos.y =
            scale * scale * (endPos.y - 2 * middlePos.y + startPos.y) + startPos.y +
            2 * scale * (middlePos.y - startPos.y);
        resultPos.z =
            scale * scale * (endPos.z - 2 * middlePos.z + startPos.z) + startPos.z +
            2 * scale * (middlePos.z - startPos.z);
		return resultPos;
	}
	private void SetCurve_Wait(Vector3 _vtHead, Vector3 _vtTail)
	{
		var middlePos = (_vtTail -_vtHead)*0.88f + _vtHead;
		middlePos.y = middlePos.y - 1;
		for (int i = 1; i < LINK_IDX_TAIL; i++)
		{
			float num = (float)i * LINK_GAP_RATIO;
			ref Vector3 reference = ref m_vtAryLinkPos[i];
			reference = GetBezierV3(_vtHead,middlePos,_vtTail,num);
		}
	}
	private void SetCurve_Dive(Vector3 _vtHead, Vector3 _vtTail)
	{
	
		for (int i = 1; i < LINK_IDX_TAIL; i++)
		{
			float num = (float)i * LINK_GAP_RATIO;
			Vector3 val = Vector3.Slerp(m_vtAryLinkPos[i], _vtTail, num);
			Vector3 val2 = m_vtAryLinkPos[i - 1];
			Vector3 val3 = m_vtAryLinkPos[i + 1];
			Vector3 val4 = Vector3.Slerp(val2, val3, num);
			ref Vector3 reference = ref m_vtAryLinkPos[i];
			reference = Vector3.Slerp(val4, val, Time.deltaTime * 1);
		}
	}

	private void SetCurve_Landing(Vector3 _vtHead, Vector3 _vtTail)
	{
		// float y = LandingFish.DEFAULT_POS.y;
		float y = FishingTempLogic.Inst.PullUpTransform.position.y;
		float y2 = _vtTail.y;
		m_vtAryLinkPos[LINK_IDX_TAIL].y = (_vtTail.y = Mathf.Max(y2, y));
		for (int i = 1; i < LINK_IDX_TAIL; i++)
		{
			float num = (float)i * LINK_GAP_RATIO;
			if (i < HALF_LINK)
			{
				Vector3 val = Vector3.Lerp(m_vtAryLinkPos[i], _vtTail, num);
				Vector3 val2 = m_vtAryLinkPos[i - 1];
				Vector3 val3 = m_vtAryLinkPos[i + 1];
				Vector3 val4 = Vector3.Lerp(val2, val3, num);
				ref Vector3 reference = ref m_vtAryLinkPos[i];
				reference = Vector3.Lerp(val4, val, Time.deltaTime * (float)i * 0.04f * 1);
			}
			else
			{
				Vector3 val2 = m_vtAryLinkPos[Mathf.Max(0, HALF_LINK - 1)];
				ref Vector3 reference2 = ref m_vtAryLinkPos[i];
				reference2 = Vector3.Lerp(val2, _vtTail, num);
			}
		}
	}

	public void SetNoneCurveRatio(float _fRatio = 0.55f)
	{
		_fRatio = Mathf.Max(0f, Mathf.Min(1f, _fRatio));
		HALF_LINK = (int)((float)MAX_LINK * _fRatio);
	}

	public void CheckColor()
	{
        SetColor(Color.white);
	}

	public void SetColor(Color _color)
	{
		m_LineRenderer.startColor = _color;
        m_LineRenderer.endColor = _color;
	}
}