namespace UnityEngine.Rendering.Universal
{
    [ExecuteAlways]
    public class VolumetricLightUpdater : MonoBehaviour
    {
        [SerializeField] private Light light;
        [SerializeField] private Camera camera;
        
        private void Update()
        {
            if (light == null || camera == null)
            {
                return;
            }
            
            Vector3 lightScreenPos = camera.WorldToScreenPoint(light.transform.position);
            
            Shader.SetGlobalFloat("_LightPosX", lightScreenPos.x);
            Shader.SetGlobalFloat("_LightPosY", lightScreenPos.y);
            Shader.SetGlobalColor("_LightColor", light.color);
        }
    }
}