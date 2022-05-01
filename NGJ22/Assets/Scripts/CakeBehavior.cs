using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CakeBehavior : MonoBehaviour
{
    [SerializeField] int dropHeight;
    [SerializeField] float dropSpeed;

    
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
    }
}
