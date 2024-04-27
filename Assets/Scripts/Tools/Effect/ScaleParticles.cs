using UnityEngine;
using System.Collections;
using System.Collections.Generic;
//例子缩放处理
public class ScaleParticles : MonoBehaviour
{
    public float ScaleSize = 1.0f;
    private List<float> initialSizes = new List<float>();

    void Awake()
    {
        // Save off all the initial scale values at start.
        ParticleSystem[] particles = gameObject.GetComponentsInChildren<ParticleSystem>();
        foreach (ParticleSystem particle in particles)
        {
            initialSizes.Add(particle.main.startSizeMultiplier);
            ParticleSystemRenderer renderer = particle.GetComponent<ParticleSystemRenderer>();
            if (renderer)
            {
                initialSizes.Add(renderer.lengthScale);
                initialSizes.Add(renderer.velocityScale);
            }
        }
    }

    void Start()
    {
        // Scale all the particle components based on parent.
        int arrayIndex = 0;
        ParticleSystem[] particles = gameObject.GetComponentsInChildren<ParticleSystem>();
        foreach (ParticleSystem particle in particles)
        {
            particle.startSize = initialSizes[arrayIndex++] * ScaleSize;
            ParticleSystemRenderer renderer = particle.GetComponent<ParticleSystemRenderer>();
            if (renderer)
            {
                renderer.lengthScale = initialSizes[arrayIndex++] *
                gameObject.transform.localScale.magnitude;
                renderer.velocityScale = initialSizes[arrayIndex++] *
                gameObject.transform.localScale.magnitude;
            }
        }
    }

    private void OnDestroy()
    {
        int arrayIndex = 0;
        ParticleSystem[] particles = gameObject.GetComponentsInChildren<ParticleSystem>();
        foreach (ParticleSystem particle in particles)
        {
            particle.startSize = initialSizes[arrayIndex++];
            ParticleSystemRenderer renderer = particle.GetComponent<ParticleSystemRenderer>();
            if (renderer)
            {
                renderer.lengthScale = initialSizes[arrayIndex++] *
                gameObject.transform.localScale.magnitude;
                renderer.velocityScale = initialSizes[arrayIndex++] *
                gameObject.transform.localScale.magnitude;
            }
        }
    }
}