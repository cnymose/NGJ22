using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TaskPaperInteraction : MonoBehaviour
{

    [SerializeField] GameObject taskPaperInHand;
    [SerializeField] GameObject taskPaperOnTable;
    [System.NonSerialized] public bool taskListHeld = false;

    [SerializeField] GameObject[] tasks;
    [SerializeField] GameObject[] tasks_InHand;

    void Start()
    {
        
    }

    void Update()
    {
        
    }

    public void CrossOutTask(int taskNumber)
    {
        tasks[taskNumber].SetActive(true);
        tasks_InHand[taskNumber].SetActive(true);
    }

    public void PickUpTaskList()
    {
        taskListHeld = true;
        taskPaperOnTable.SetActive(false);
        taskPaperInHand.SetActive(true);
    }

    public void PutDownTaskList()
    {
        taskListHeld = false;
        taskPaperOnTable.SetActive(true);
        taskPaperInHand.SetActive(false);
    }
}
