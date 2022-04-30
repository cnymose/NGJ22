using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectSnapping : MonoBehaviour
{

    [SerializeField] GameObject snapPoint;
    [SerializeField] float snapDistance;

    [SerializeField] GameObject[] snappedVisuals;

    [SerializeField] GameObject associatedCharacter;
    [SerializeField] int taskNumber;

    void Start()
    {
        
    }

    void Update()
    {
        
    }

    public bool CheckSnapToPoint()
    {
        if (Vector3.Distance(gameObject.transform.position, snapPoint.transform.position) < snapDistance)
        {
            SnapToPoint();
            return true;
        }
        return false;
    }

    void SnapToPoint()
    {
        Debug.Log(associatedCharacter);
        for(int i = 0; i < snappedVisuals.Length; i++)
        {
            snappedVisuals[i].SetActive(true);
        }
        associatedCharacter.GetComponent<TaskPaperInteraction>().CrossOutTask(taskNumber);
        Destroy(gameObject);
    }
}
