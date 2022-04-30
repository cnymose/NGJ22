using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectSnapping : MonoBehaviour
{

    [SerializeField] GameObject snapPoint;
    [SerializeField] float snapDistance;
    [System.NonSerialized] public bool snapped = false;


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
        snapped = true;
        gameObject.GetComponent<Rigidbody>().useGravity = false;
        gameObject.GetComponent<SphereCollider>().enabled = false;
        gameObject.GetComponent<Rigidbody>().constraints = RigidbodyConstraints.FreezeAll;
        gameObject.transform.position = snapPoint.transform.position;
    }
}
