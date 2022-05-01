using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Highlight : MonoBehaviour
{
    private static int outlinePropertyId = Shader.PropertyToID("_OutlineWidth");
    private static int outlineColorPropertyId = Shader.PropertyToID("_OutlineColor");
    
    [ColorUsage(false, true), SerializeField] private Color outlineColor = new Color(2.75f,2.75f, 1.35f, 1);

    private Renderer[] targetRenderers;

    private void Awake()
    {
        targetRenderers = GetComponentsInChildren<Renderer>();
    }
    
    public void EnableHighlight()
    {
        foreach (var targetRenderer in targetRenderers)
        {
            targetRenderer.material.SetFloat(outlinePropertyId, 4);
            targetRenderer.material.SetColor(outlineColorPropertyId, outlineColor);
        }
    }

    public void DisableHighlight()
    {
        foreach (var targetRenderer in targetRenderers)
        {
            targetRenderer.material.SetFloat(outlinePropertyId, 0);
            targetRenderer.material.SetColor(outlineColorPropertyId, Color.black);
        }
    }
}
