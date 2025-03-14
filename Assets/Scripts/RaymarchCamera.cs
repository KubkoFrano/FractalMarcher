using UnityEngine;
using static UnityEditor.PlayerSettings;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class RaymarchCamera : MonoBehaviour
{
    [SerializeField]
    private Shader _shader;

    [SerializeField]
    private int _maxSteps;

    [SerializeField]
    private float _minDistance;

    [SerializeField]
    private Vector4 _sphere1;

    [SerializeField] private Color _color1;
    [SerializeField] private Color _color2;
    [SerializeField] private Color _color3;

    [SerializeField] private int _iterations;
    [SerializeField] private float _scale;
    [SerializeField] private float _power;

    public Material _raymarchMaterial
    {
        get
        {
            if (!_raymarchMat && _shader)
            {
                _raymarchMat = new Material(_shader);
                _raymarchMat.hideFlags = HideFlags.HideAndDontSave;
            }
            return _raymarchMat;
        }
    }

    private Material _raymarchMat;

    public Camera _camera
    {
        get
        {
            if (!_cam)
            {
                _cam = GetComponent<Camera>();
            }
            return _cam;
        }
    }

    private Camera _cam;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (!_raymarchMaterial)
        {
            Graphics.Blit(source, destination);
            return;
        }

        _raymarchMaterial.SetMatrix("_CamFrustum", CamFrustum(_camera));
        _raymarchMaterial.SetMatrix("_CamToWorld", _camera.cameraToWorldMatrix);
        _raymarchMaterial.SetInt("_maxSteps", _maxSteps);
        _raymarchMaterial.SetFloat("_minDistance", _minDistance);
        _raymarchMaterial.SetVector("_sphere1", _sphere1);

        _raymarchMaterial.SetVector("_color1", _color1);
        _raymarchMaterial.SetVector("_color2", _color2);
        _raymarchMaterial.SetVector("_color3", _color3);

        _raymarchMaterial.SetInt("_iterations", _iterations);
        _raymarchMaterial.SetFloat("_scale", _scale);
        _raymarchMaterial.SetFloat("_power", _power);

        RenderTexture.active = destination;
        GL.PushMatrix();
        GL.LoadOrtho();
        _raymarchMaterial.SetPass(0);
        GL.Begin(GL.QUADS);

        //BL
        GL.MultiTexCoord2(0, 0.0f, 0.0f);
        GL.Vertex3(0.0f, 0.0f, 3.0f);

        //BR
        GL.MultiTexCoord2(0, 1.0f, 0.0f);
        GL.Vertex3(1.0f, 0.0f, 2.0f);

        //TR
        GL.MultiTexCoord2(0, 1.0f, 1.0f);
        GL.Vertex3(1.0f, 1.0f, 1.0f);

        //TL
        GL.MultiTexCoord2(0, 0.0f, 1.0f);
        GL.Vertex3(0.0f, 1.0f, 0.0f);

        GL.End();
        GL.PopMatrix();
    }

    private Matrix4x4 CamFrustum(Camera cam)
    {
        Matrix4x4 frustum = Matrix4x4.identity;
        float fov = Mathf.Tan((cam.fieldOfView * 0.5f) * Mathf.Deg2Rad);

        Vector3 goUp = Vector3.up * fov;
        Vector3 goRight = Vector3.right * fov * cam.aspect;

        Vector3 TL = (-Vector3.forward - goRight + goUp);
        Vector3 TR = (-Vector3.forward + goRight + goUp);
        Vector3 BR = (-Vector3.forward + goRight - goUp);
        Vector3 BL = (-Vector3.forward - goRight - goUp);

        frustum.SetRow(0, TL);
        frustum.SetRow(1, TR);
        frustum.SetRow(2, BR);
        frustum.SetRow(3, BL);

        return frustum;
    }

    private float distanceFromMandelbulb()
    {
        Vector3 z = transform.position;
        float dr = 1f;
        float r = 0f;
        int i = 0;
        for (; i < _iterations; i++)
        {
            r = z.magnitude;
            if (r > 1.15) break;

            // convert to polar coordinates
            float theta = Mathf.Acos(z.z / r);
            float phi = Mathf.Atan2(z.y, z.x);
            dr = Mathf.Pow(r, _power - 1f) * _power * dr + 1f;

            // scale and rotate the point
            float zr = Mathf.Pow(r, _power);
            theta = theta * _power;
            phi = phi * _power;

            // convert back to cartesian coordinates
            z = zr * new Vector3(Mathf.Sin(theta) * Mathf.Cos(phi), Mathf.Sin(phi) * Mathf.Sin(theta), Mathf.Cos(theta));
            z += transform.position;
        }

        return 0.5f * Mathf.Log(r) * r / dr;
    }

    private void Update()
    {
        _minDistance = Mathf.Clamp(distanceFromMandelbulb() / 1000, 0.0000001f, 0.001f);
    }
}
