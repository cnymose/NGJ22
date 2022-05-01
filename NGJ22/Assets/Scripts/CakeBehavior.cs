using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CakeBehavior : MonoBehaviour
{
    [SerializeField] int dropHeight;
    [SerializeField] float dropSpeed;
    [SerializeField] int confettiCounter = 150;
    [SerializeField] GameObject confetti;

    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (transform.position.y >= dropHeight)
        {
            transform.Translate(new Vector3(0, -1, 0) * dropSpeed * Time.deltaTime);
        }
        confettiCounter--;

        if(confettiCounter < 0)
        {
            Instantiate(confetti, transform.position, Quaternion.identity);
            confettiCounter = 150;
        }
    }
}
