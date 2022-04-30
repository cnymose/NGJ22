using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TaskPaperInteraction : MonoBehaviour
{

    [SerializeField] GameObject taskPaperInHand;
    [System.NonSerialized] public bool taskListHeld = false;

    void Start()
    {
        
    }

    void Update()
    {
        
    }

    public void PickUpTaskList()
    {
        taskListHeld = true;
        gameObject.GetComponent<MeshRenderer>().enabled = false;
        taskPaperInHand.SetActive(true);
    }

    public void PutDownTaskList()
    {
        taskListHeld = false;
        gameObject.GetComponent<MeshRenderer>().enabled = true;
        taskPaperInHand.SetActive(false);
    }
}
