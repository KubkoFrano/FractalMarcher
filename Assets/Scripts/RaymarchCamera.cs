using UnityEngine;
using System.Collections.Generic;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class RaymarchCamera : MonoBehaviour
{
    [SerializeField]
    private Shader _shader;

    [SerializeField]
    private int _maxSteps;

    [SerializeField] private float _epsilonMin;
    [SerializeField] private float _epsilonMax;

    [SerializeField] private int _iterations;
    [SerializeField] private float _power;

    [SerializeField] private Vector3[] _lights = new Vector3[6];
    [SerializeField] private Color[] _colors = new Color[6];

    [SerializeField][Range(-1f, 1f)] private float _seedX;
    [SerializeField][Range(-1f, 1f)] private float _seedY;
    [SerializeField][Range(-1f, 1f)] private float _seedZ;
    [SerializeField][Range(-1f, 1f)] private float _seedW;

    [SerializeField][Range(0f, 1f)] private float _par;

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

        _raymarchMaterial.SetFloat("_epsilonMin", _epsilonMin);
        _raymarchMaterial.SetFloat("_epsilonMax", _epsilonMax);

        _raymarchMaterial.SetInt("_iterations", _iterations);
        _raymarchMaterial.SetFloat("_power", _power);

        _raymarchMaterial.SetVectorArray("_lights", ConvertLights(_lights));
        _raymarchMaterial.SetVectorArray("_colors", ConvertColors(_colors));

        _raymarchMaterial.SetVector("_seed", new Vector4(_seedX, _seedY, _seedZ, _seedW));
        _raymarchMaterial.SetFloat("_par", _par);

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

    private List<Vector4> ConvertLights(Vector3[] lights)
    {
        List<Vector4> result = new List<Vector4>();
        foreach (Vector3 light in lights)
        {
            result.Add(new Vector4(light.x, light.y, light.z, 0f));
        }
        return result;
    }

    private List<Vector4> ConvertColors(Color[] colors)
    {
        List<Vector4> result = new List<Vector4>();
        foreach (Color color in colors)
        {
            result.Add(new Vector4(color.r, color.g, color.b, color.a));
        }
        return result;
    }
}
