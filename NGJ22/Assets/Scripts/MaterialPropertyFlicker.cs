using UnityEngine;


public class MaterialPropertyFlicker : MonoBehaviour
{

   [SerializeField] private Renderer renderer;
   [SerializeField] private string propertyName;
   [SerializeField] private float valueMin;
   [SerializeField] private float valueMax;
   [SerializeField] private float flickerDuration;

   private void Update()
   {
      float t = Mathf.PingPong(Time.time, flickerDuration) / flickerDuration;
      renderer.material.SetFloat( propertyName, Mathf.Lerp(valueMin, valueMax, t));
   }
}
