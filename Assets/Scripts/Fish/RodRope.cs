// RodRope
using UnityEngine;

public class RodRope : MonoBehaviour
{
	private const int MAX_LINK = 6;

	public const string NAME_LINE_ROOT = "LineRoot{0}";

	public static RodRope Inst;

	[HideInInspector]
	public Transform m_Transform;

	private LineRenderer m_LineRenderer;

	private Transform[] m_trsAryLineRoots = (Transform[])(object)new Transform[6];

	private void Awake()
	{
		Inst = this;
		m_Transform = ((Component)this).transform;
		m_LineRenderer = ((Component)this).GetComponent<LineRenderer>();
		m_LineRenderer.positionCount = 6;
	}

	private void Start()
	{
		ResetLink();
		SetLineWidth(0.002f, 0.002f);
	}

	private void Update()
	{
		ResetLineRenderPos();
	}

	public void ResetLink()
	{
		for (int i = 0; i < 6; i++)
		{
			string value = $"LineRoot{i}";
			Transform[] componentsInChildren = ((Component)transform).GetComponentsInChildren<Transform>();
			Transform[] array = componentsInChildren;
			foreach (Transform val in array)
			{
				if (((Object)val).name.Contains(value))
				{
					m_trsAryLineRoots[i] = val;
					break;
				}
			}
		}
	}

	private void ResetLineRenderPos()
	{
		for (int i = 0; i < 6 && !((Object)(object)m_trsAryLineRoots[i] == (Object)null); i++)
		{
			m_LineRenderer.SetPosition(i, m_trsAryLineRoots[i].position);
		}
	}

	public void SetLineWidth(float _fStartWidth, float _fEndWidth)
	{
        m_LineRenderer.startWidth = _fStartWidth;
        m_LineRenderer.endWidth = _fEndWidth;
	}

	public void SetColor(Color _color)
	{
        m_LineRenderer.startColor = _color;
        m_LineRenderer.endColor = _color;
	}
}