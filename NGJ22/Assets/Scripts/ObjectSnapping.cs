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
    [SerializeField] int characterID;

    [SerializeField] GameObject confetti;

    void Start()
    {
        
    }

    void Update()
    {
        
    }

    public int CheckSnapToPoint()
    {
        if (Vector3.Distance(gameObject.transform.position, snapPoint.transform.position) < snapDistance)
        {
            SnapToPoint();
            return characterID;
        }
        return 0;
    }

    void SnapToPoint()
    {
        for(int i = 0; i < snappedVisuals.Length; i++)
        {
            snappedVisuals[i].SetActive(true);
        }
        Instantiate(confetti, snapPoint.transform.position, Quaternion.identity);
        associatedCharacter.GetComponent<TaskPaperInteraction>().CrossOutTask(taskNumber);
        Destroy(gameObject);
    }
}
