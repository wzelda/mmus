using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BezierSolution;
using XLua;
//水收集特效
[LuaCallCSharp]
public class WaterCollect : MonoBehaviour {
    enum WaterStatus  {
        NoActive,
        Bomb,
        Collect,
        Finish
    }

    static GameObject[] splineGoList;
    static BezierSpline[] splineList;
    static float[] flySpeed;
    static float[] progress;
    static ParticleSystem.Particle[] m_Particles1, m_Particles2 = null;

    float flyTime = 0.8f;
    float bombTime = 0.6f;
    float curTime;
    WaterStatus status = WaterStatus.NoActive;

    GameObject goWaterEff;
    float rootPosY;
    Vector3 boxBolltePos, boxWaterPos;

    ParticleSystem m_System1, m_System2;
    int pN = 18;

    Vector3 curPoint;

    private void Init()
    {
        if (splineGoList == null)
        {
            GameObject splineRoot = new GameObject("splineRoot");
            DontDestroyOnLoad(splineRoot);
            splineGoList = new GameObject[pN];
            splineList = new BezierSpline[pN];
            for (int i = 0; i < pN; i++)
            {
                splineGoList[i] = new GameObject("Spline" + Time.time);
                splineGoList[i].transform.parent = splineRoot.transform;
                splineList[i] = splineGoList[i].AddComponent<BezierSpline>();
                splineList[i].Initialize(4);
            }
            progress = new float[pN];
            flySpeed = new float[pN];
            m_Particles2 = new ParticleSystem.Particle[pN];
            m_Particles1 = new ParticleSystem.Particle[pN];
        }
    }

    private void OnEnable()
    {
        status = WaterStatus.NoActive;
    }

    public void StartCollect(GameObject _go, float groundY, Vector3 _boxBolltePos,Vector3 _boxWaterPos,float _bombTime, float _flyTime)
    {
        goWaterEff = _go;
        Transform flyTrans = goWaterEff.transform;
        rootPosY = groundY + 0.1f;
        m_System1 = flyTrans.Find("zong/feijian1guangyun").GetComponent<ParticleSystem>();
        m_System2 = flyTrans.Find("zong/feijian1").GetComponent<ParticleSystem>();
        flyTime = _flyTime;
        bombTime = _bombTime;
        boxBolltePos = _boxBolltePos;
        boxWaterPos = _boxWaterPos;
        status = WaterStatus.Bomb;
        curTime = 0;
        Init();
    }
    //Spline 曲线
    private void CreateSpline()
    {
        Transform flyTrans = goWaterEff.transform;
        float normalDis = Vector3.Distance(flyTrans.position, boxWaterPos);
        float speed = normalDis / flyTime;
        for (int i = 0; i < pN; i++)
        {
            Vector3 startPos = m_Particles2[i].position;
            Vector3 forward = (boxWaterPos - startPos).normalized;
            Vector3 up = flyTrans.up;
            float flyDis = Vector3.Distance(startPos, boxWaterPos);
            splineList[i][0].position = startPos;
            splineList[i][1].position = startPos + forward * flyDis * 0.6f + up * 2f;
            splineList[i][2].position = boxBolltePos - forward * 0.2f;
            splineList[i][3].position = boxWaterPos + forward * 0.2f;
            splineList[i].AutoConstructSpline();
            progress[i] = 0;
            float rate = splineList[i].Length / normalDis;
            rate = rate * rate * 0.5f;
            flySpeed[i] = speed * rate;
        }
    }

    void CheckWaterParticle(ParticleSystem.Particle[] ps, int num)
    {
        Vector3 tempPos;
        for (int i = 1; i < num; i++)
        {
            tempPos = ps[i].position;
            if (tempPos.y < rootPosY)
            {
                tempPos.y = rootPosY;
                ps[i].position = tempPos;
            }
        }
    }

    public void LateUpdate()
    {
        float deltaTime = Time.deltaTime;
        curTime = curTime + deltaTime;
        if (status == WaterStatus.Bomb)
        {
            //判断落到地面上
            int pN1 = m_System1.GetParticles(m_Particles1);
            int pN2 = m_System2.GetParticles(m_Particles2);
            CheckWaterParticle(m_Particles1, pN1);
            CheckWaterParticle(m_Particles2, pN2);
            m_System1.SetParticles(m_Particles1, pN1);
            m_System2.SetParticles(m_Particles2, pN2);
            if (curTime > bombTime)
            {
                CreateSpline();
                status = WaterStatus.Collect;
                curTime = 0;
            }
        }
        else if (status == WaterStatus.Collect)
        {
            bool isOver = true;
            if (goWaterEff)
            {
                float rate = curTime / flyTime;
                int pN1 = m_System1.GetParticles(m_Particles1);
                int pN2 = m_System2.GetParticles(m_Particles2);
                Vector3 tempPoint;
                for (int i = 0; i < pN; i++)
                {
                    if (progress[i] < 1.1)
                    {
                        isOver = false;
                    }
                    else
                    {
                        m_Particles1[i].remainingLifetime = 0;
                        m_Particles2[i].remainingLifetime = 0;
                        continue;
                    }
                    curPoint = splineList[i].MoveAlongSpline(ref progress[i], flySpeed[i] * deltaTime);
                    if (i < pN1)
                    {
                        tempPoint.y = curPoint.y;
                        tempPoint.x = Mathf.Lerp(m_Particles1[i].position.x, curPoint.x, rate);
                        tempPoint.z = Mathf.Lerp(m_Particles1[i].position.z, curPoint.z, rate);
                        m_Particles1[i].position = tempPoint;
                    }
                    if (i < pN2)
                    {
                        tempPoint.y = curPoint.y;
                        tempPoint.x = Mathf.Lerp(m_Particles2[i].position.x, curPoint.x, rate);
                        tempPoint.z = Mathf.Lerp(m_Particles2[i].position.z, curPoint.z, rate);
                        m_Particles2[i].position = tempPoint;
                    }
                }
                m_System1.SetParticles(m_Particles1, pN1);
                m_System2.SetParticles(m_Particles2, pN2);
            }
            if (isOver)
            {
                status = WaterStatus.Finish;
                return;
            }
        }
    }
    public bool IsFinish()
    {
        return status == WaterStatus.Finish;
    }

}
