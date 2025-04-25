using UnityEngine;
using UnityEngine.InputSystem;

public class CameraController : MonoBehaviour
{
    [SerializeField] private SettingsPanel settings;

    [SerializeField] private float moveSpeed = 5f;
    [SerializeField] private float lookSpeed = 0.5f;
    [SerializeField] private float updateSpeedBy = 0.2f;
    [SerializeField] private float minSpeed = 0.00001f;
    [SerializeField] private float maxSpeed = 10;

    private Vector2 moveInput;
    private Vector2 lookInput;
    private float rotationX = 0;
    private bool canMove = true;

    private void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    private void Update()
    {
        if (!canMove)
            return;

        Vector3 move = new Vector3(moveInput.x, 0, moveInput.y) * moveSpeed * Time.deltaTime;
        transform.Translate(move, Space.Self);

        transform.Rotate(Vector3.up * lookInput.x * lookSpeed, Space.World);

        rotationX -= lookInput.y * lookSpeed;
        rotationX = Mathf.Clamp(rotationX, -90f, 90f);
        transform.localRotation = Quaternion.Euler(rotationX, transform.eulerAngles.y, 0f);
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
        moveSpeed = Mathf.Clamp(moveSpeed * ( 1 + scrollValue * updateSpeedBy), minSpeed, maxSpeed);
    }

    public void PauseResume(InputAction.CallbackContext context)
    {
        if (canMove)
            Pause();
        else
            Resume();
    }

    private void Pause()
    {
        canMove = false;
        Cursor.lockState = CursorLockMode.None;
        Cursor.visible = true;
        settings.Pause();
    }

    private void Resume()
    {
        canMove = true;
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
        settings.Resume();
    }
}
