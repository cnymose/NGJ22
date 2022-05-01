using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundtrackManager : MonoBehaviour
{
    private int TVItemsCollected = 0;
    private int ChairItemsCollected = 0;
    private int TotalItemsCollected = 0;
    private FMODUnity.StudioEventEmitter audio;
    private FMODUnity.StudioEventEmitter interactSound;
    private WhiteNoiseHandler whiteNoise;

    private void Start() {
        audio = GetComponent<FMODUnity.StudioEventEmitter>();
        whiteNoise = FindObjectOfType<WhiteNoiseHandler>();
        interactSound = transform.GetChild(0).GetComponent<FMODUnity.StudioEventEmitter>();
    }

    private void Update() {
        // if (Input.anyKeyDown)
        //     Interact();
    }

    public void AddToTV() {
        if (TotalItemsCollected == 0)
            audio.EventInstance.start();
        TVItemsCollected++;
        TotalItemsCollected++;
        audio.EventInstance.setParameterByName("EliseItems", TVItemsCollected);
        audio.EventInstance.setParameterByName("TotalItems", TVItemsCollected+ChairItemsCollected);
        whiteNoise.volume((1 -  (float)TotalItemsCollected/6));
    }

    public void AddToChair() {
        if (TotalItemsCollected == 0)
            audio.EventInstance.start();
        ChairItemsCollected++;
        TotalItemsCollected++;
        audio.EventInstance.setParameterByName("BobbyItems", ChairItemsCollected);
        audio.EventInstance.setParameterByName("TotalItems", ChairItemsCollected+TVItemsCollected);
        whiteNoise.volume((1 -  (float)TotalItemsCollected/6));
    }
    public void Interact() {
        interactSound.Play();
    }

    public void QueBirthdaySong() {
        interactSound.Play();
        audio.EventInstance.setParameterByName("StartBirthday", 1);
    }


}
