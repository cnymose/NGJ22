using UnityEngine;

public class LightFlicker : MonoBehaviour
{
   [SerializeField] private Light light;
   [SerializeField] private float variance;
   [SerializeField] private float flickerDuration;

   private float baseValue;

   private void Start()
   {
      baseValue = light.intensity;
   }
   
   private void Update()
   {
      float t = Mathf.PingPong(Time.time, flickerDuration) / flickerDuration;
      light.intensity = baseValue + variance * t;
   }
}
