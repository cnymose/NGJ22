using UnityEngine;
using UnityEngine.UI;

public class FirstPersonController : MonoBehaviour
{
    [SerializeField] float speed = 2;
    [SerializeField] float rotSpeed = 1;
    [SerializeField] float tiltSpeed = 1;

    [SerializeField] GameObject camera;
    [SerializeField] float lookDownConstraint;
    [SerializeField] float lookUpConstraint;
    bool taskListHeld = false;

    float headTilt = 0f;

    [SerializeField] float interactLength = 100f;
    [SerializeField] GameObject soundStuff;


    bool holdingItem = false;
    GameObject heldItem;
    [SerializeField] GameObject taskPaper;
    [SerializeField] GameObject fade;
    float fadeValue = 255;
    [SerializeField] float fadeSpeed;
    private Highlight currentHighlight;
    
    void Start()
    {
        Cursor.visible = false;
        Cursor.lockState = CursorLockMode.Locked;
        taskPaper.transform.parent.GetComponent<TaskPaperInteraction>().PickUpTaskList();
    }

    void Update()
    {
        BodyMovement();
        CameraMovement();
        RayCast();
        HeldItemVelocity();
        FadeIntro();
    }
    
    void BodyMovement()
    {
        float x = Input.GetAxis("Horizontal");
        float z = Input.GetAxis("Vertical");
        Vector3 movement = new Vector3(x, 0, z);
        movement = Vector3.ClampMagnitude(movement, 1);
        transform.Translate(movement * speed * Time.deltaTime);
    }

    void CameraMovement()
    {
        float x = Input.GetAxis("Mouse X");
        float y = Input.GetAxis("Mouse Y");
        Vector3 bodyRotation = new Vector3(0, x, 0);

        headTilt -= y * tiltSpeed; 
        headTilt = Mathf.Clamp(headTilt, lookUpConstraint, lookDownConstraint);

        transform.Rotate(bodyRotation * rotSpeed);
        camera.transform.localRotation = Quaternion.Euler(headTilt, 0f, 0f);
    }

    void RayCast()
    {
        Vector3 rayOrigin = new Vector3(0.5f, 0.5f, 0f);

        Ray ray = Camera.main.ViewportPointToRay(rayOrigin);

        Debug.DrawRay(ray.origin, ray.direction * interactLength, Color.red);

        RaycastHit hit;
        if (taskPaper != null && Input.GetMouseButtonDown(0) && holdingItem == false && taskPaper.transform.parent.GetComponent<TaskPaperInteraction>().taskListHeld == true)
        {
            taskPaper.transform.parent.GetComponent<TaskPaperInteraction>().PutDownTaskList();
        }
        else if (Physics.Raycast(ray, out hit, interactLength))
        {
            DoHighlight(hit.transform);
            
            if (Input.GetMouseButtonDown(0) && !holdingItem)
            {
                if (hit.transform.gameObject.tag == "Interactable")
                {
                    heldItem = hit.transform.gameObject;
                    heldItem.GetComponent<Rigidbody>().useGravity = false;
                    foreach (Collider c in heldItem.GetComponents<Collider>())
                    {
                        c.enabled = false;
                    }
                    heldItem.GetComponent<Rigidbody>().constraints = RigidbodyConstraints.FreezeAll;
                    heldItem.transform.parent = camera.transform;
                    holdingItem = true;
                }
                else if (hit.transform.gameObject.tag == "TaskPaper")
                {
                    taskPaper = hit.transform.gameObject;
                    taskPaper.transform.parent.GetComponent<TaskPaperInteraction>().PickUpTaskList();
                }
            }
        }
        else
        {
            EndHighlight();
        }
        if (Input.GetMouseButtonUp(0) && holdingItem)
        {
            if (Physics.Raycast(ray, out hit, interactLength+10) && hit.transform.gameObject.tag != "Interactable" && Vector3.Distance(camera.transform.position, heldItem.transform.position) > Vector3.Distance(camera.transform.position, hit.point))
            {
                heldItem.transform.position = hit.point + new Vector3(0,.1f,0);
            }
            
            heldItem.GetComponent<Rigidbody>().useGravity = true;
            foreach (Collider c in heldItem.GetComponents<Collider>())
            {
                c.enabled = true;
            }
            heldItem.GetComponent<Rigidbody>().constraints = RigidbodyConstraints.None;
            heldItem.transform.parent = null;
            holdingItem = false;
            int objectSnapID = heldItem.GetComponent<ObjectSnapping>().CheckSnapToPoint();
            if(objectSnapID == 1) //Bobby
            {
                soundStuff.GetComponent<SoundtrackManager>().AddToChair();
            } else if (objectSnapID == 2) //Elise
            {
                soundStuff.GetComponent<SoundtrackManager>().AddToTV();
            }
            heldItem = null;
        }
    }

    void FadeIntro()
    {
        if(fadeValue > 0)
        {
            fade.GetComponent<Image>().color = new Color32(0, 0, 0, (byte)fadeValue);
            fadeValue -= fadeSpeed;
        }
    }

    void HeldItemVelocity()
    {
        if(holdingItem == true)
        {
            Debug.Log(heldItem.GetComponent<Rigidbody>().velocity);
        } 
    }


    private void DoHighlight(Transform transform)
    {
        if (!(transform.tag == "Interactable" || transform.tag == "TaskPaper"))
        {
            EndHighlight();
        }
        var highlight = transform.GetComponent<Highlight>();
        if (highlight != null)
        {
            EndHighlight();
            currentHighlight = highlight;
            currentHighlight.EnableHighlight();
        }
    }

    private void EndHighlight()
    {
        if (currentHighlight != null)
        {
            currentHighlight.DisableHighlight();
            currentHighlight = null;
        }
    }
}
