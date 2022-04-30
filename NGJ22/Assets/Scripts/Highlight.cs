using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Highlight : MonoBehaviour
{
    private static int outlinePropertyId = Shader.PropertyToID("_OutlineWidth");
    private static int outlineColorPropertyId = Shader.PropertyToID("_OutlineColor");

    [SerializeField] private Renderer[] targetRenderers;
    [ColorUsage(false, true), SerializeField] private Color outlineColor;
    
    public void EnableHighlight()
    {
        foreach (var targetRenderer in targetRenderers)
        {
            targetRenderer.material.SetFloat(outlinePropertyId, 2);
            targetRenderer.material.SetColor(outlineColorPropertyId, outlineColor);
        }
    }

    public void DisableHighlight()
    {
        foreach (var targetRenderer in targetRenderers)
        {
            targetRenderer.material.SetFloat(outlinePropertyId, 0);
        }
    }
}
