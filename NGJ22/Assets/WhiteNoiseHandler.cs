using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WhiteNoiseHandler : MonoBehaviour
{
    private FMODUnity.StudioEventEmitter noise;

    // Start is called before the first frame update
    void Start()
    {
        noise = GetComponent<FMODUnity.StudioEventEmitter>();
        
    }

    // Update is called once per frame
    public void volume(float newVol)
    {
        noise.EventInstance.setParameterByName("Noise", newVol);
    }
}
