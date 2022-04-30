using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectSnapping : MonoBehaviour
{

    [SerializeField] GameObject snapPoint;
    [SerializeField] float snapDistance;

    [SerializeField] GameObject[] snappedVisuals;


    void Start()
    {
        
    }

    void Update()
    {
        
    }

    public void CheckSnapToPoint()
    {
        if (Vector3.Distance(gameObject.transform.position, snapPoint.transform.position) < snapDistance)
        {
            SnapToPoint();
        }
    }

    void SnapToPoint()
    {
        for(int i = 0; i < snappedVisuals.Length; i++)
        {
            snappedVisuals[i].SetActive(true);
        }
        Destroy(gameObject);
    }
}
