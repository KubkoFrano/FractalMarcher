using UnityEngine;
using UnityEngine.InputSystem;

public class CameraController : MonoBehaviour
{
    [SerializeField] private float moveSpeed = 5f;
    [SerializeField] private float lookSpeed = 0.5f;
    [SerializeField] private float updateSpeedBy = 0.2f;
    [SerializeField] private float minSpeed = 1;
    [SerializeField] private float maxSpeed = 10;

    private Vector2 moveInput;
    private Vector2 lookInput;

    private void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    private void Update()
    {
        Vector3 move = new Vector3(moveInput.x, 0, moveInput.y) * moveSpeed * Time.deltaTime;
        transform.Translate(move, Space.Self);

        transform.Rotate(Vector3.up * lookInput.x * lookSpeed, Space.World);
        transform.Rotate(Vector3.left * lookInput.y * lookSpeed);
    }

    public void Move(InputAction.CallbackContext context)
    {
        moveInput = context.ReadValue<Vector2>();
    }

    public void Look(InputAction.CallbackContext context)
    {
        lookInput = context.ReadValue<Vector2>();
    }

    public void SetSpeed(InputAction.CallbackContext context)
    {
        float scrollValue = context.ReadValue<float>();
        moveSpeed = Mathf.Clamp(moveSpeed + scrollValue * updateSpeedBy, minSpeed, maxSpeed);
    }
}
