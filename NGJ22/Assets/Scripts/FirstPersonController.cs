using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FirstPersonController : MonoBehaviour
{
    [SerializeField] float speed = 2;
    [SerializeField] float rotSpeed = 1;
    [SerializeField] float tiltSpeed = 1;

    [SerializeField] GameObject camera;
    [SerializeField] float lookDownConstraint;
    [SerializeField] float lookUpConstraint;

    float headTilt = 0f;

    [SerializeField] float interactLength = 100f;

    void Start()
    {
        Cursor.visible = false;
        Cursor.lockState = CursorLockMode.Locked;
    }

    void Update()
    {
        BodyMovement();
        CameraMovement();
        RayCast();
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
        if (Physics.Raycast(ray, out hit, interactLength))
        {
            
        }
    }
}
