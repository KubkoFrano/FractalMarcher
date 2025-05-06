using System;
using UnityEngine;

public class Settings
{
    private static Settings instance = null;
    private Settings()
    {
        //Load values or set default

        //Ray marching
        if (PlayerPrefs.HasKey("maxSteps"))
            _maxSteps = PlayerPrefs.GetInt("maxSteps");
        else
            maxSteps = 128;

        //Epsilon
        if (PlayerPrefs.HasKey("epsilonMin"))
            _epsilonMin = PlayerPrefs.GetFloat("epsilonMin");
        else
            epsilonMin = 0.0000001f;

        if (PlayerPrefs.HasKey("epsilonMax"))
            _epsilonMax = PlayerPrefs.GetFloat("epsilonMax");
        else
            epsilonMax = 0.001f;

        //Lighting
        if (PlayerPrefs.HasKey("colorMultiplier"))
            _colorMultiplier = PlayerPrefs.GetFloat("colorMultiplier");
        else
            colorMultiplier = 1f;

        //Mandelbulb
        if (PlayerPrefs.HasKey("iterations"))
            _iterations = PlayerPrefs.GetInt("iterations");
        else
            iterations = 70;

        if (PlayerPrefs.HasKey("power"))
            _power = PlayerPrefs.GetFloat("power");
        else
            power = 8f;

        //Julia
        if (PlayerPrefs.HasKey("seedX"))
            _seedX = PlayerPrefs.GetFloat("seedX");
        else
            seedX = -0.291f;
        if (PlayerPrefs.HasKey("seedY"))
            _seedY = PlayerPrefs.GetFloat("seedY");
        else
            seedY = -0.5f;
        if (PlayerPrefs.HasKey("seedZ"))
            _seedZ = PlayerPrefs.GetFloat("seedZ");
        else
            seedZ = -0.05f;
        if (PlayerPrefs.HasKey("seedW"))
            _seedW = PlayerPrefs.GetFloat("seedW");
        else
            seedW = -0.67f;
        if (PlayerPrefs.HasKey("par"))
            _par = PlayerPrefs.GetFloat("par");
        else
            par = 0f;

        //Fractal
        if (PlayerPrefs.HasKey("fractal"))
            _fractal = (Fractal)PlayerPrefs.GetInt("fractal");
        else
            fractal = Fractal.Mandelbulb;
    }

    public static Settings GetInstance()
    {
        if (instance == null)
            instance = new Settings();
        return instance;
    }

    //Ray marching
    private int _maxSteps;
    public int maxSteps
    {
        get
        {
            return _maxSteps;
        }
        set
        {
            _maxSteps = value;
            PlayerPrefs.SetInt("maxSteps", value);
        }
    }

    //Epsilon
    private float _epsilonMin;
    public float epsilonMin
    {
        get 
        {
            return _epsilonMin;
        }
        set
        {
            _epsilonMin = value;
            PlayerPrefs.SetFloat("epsilonMin", value);
        }
    }

    private float _epsilonMax;
    public float epsilonMax
    {
        get
        {
            return _epsilonMax;
        }
        set
        {
            _epsilonMax = value;
            PlayerPrefs.SetFloat("epsilonMax", value);
        }
    }

    //Lighting
    private float _colorMultiplier;
    public float colorMultiplier
    {
        get
        {
            return _colorMultiplier;
        }
        set
        {
            _colorMultiplier = value;
            PlayerPrefs.SetFloat("colorMultiplier", value);
        }
    }

    //Mandelbulb
    private int _iterations;
    public int iterations
    {
        get
        {
            return _iterations;
        }
        set
        {
            _iterations = value;
            PlayerPrefs.SetInt("iterations", value);
        }
    }

    private float _power;
    public float power
    {
        get
        {
            return _power;
        }
        set
        {
            _power = value;
            PlayerPrefs.SetFloat("power", value);
        }
    }

    //Julia
    private float _seedX;
    public float seedX
    {
        get
        {
            return _seedX;
        }
        set
        {
            _seedX = value;
            PlayerPrefs.SetFloat("seedX", value);
        }
    }

    private float _seedY;
    public float seedY
    {
        get
        {
            return _seedY;
        }
        set
        {
            _seedY = value;
            PlayerPrefs.SetFloat("seedY", value);
        }
    }

    private float _seedZ;
    public float seedZ
    {
        get
        {
            return _seedZ;
        }
        set
        {
            _seedZ = value;
            PlayerPrefs.SetFloat("seedZ", value);
        }
    }

    private float _seedW;
    public float seedW
    {
        get
        {
            return _seedW;
        }
        set
        {
            _seedW = value;
            PlayerPrefs.SetFloat("seedW", value);
        }
    }

    private float _par;
    public float par
    {
        get
        {
            return _par;
        }
        set
        {
            _par = value;
            PlayerPrefs.SetFloat("par", value);
        }
    }

    //Fractal
    private Fractal _fractal;
    public Fractal fractal
    {
        get
        {
            return _fractal;
        }
        set
        {
            _fractal = value;
            PlayerPrefs.SetInt("fractal", (int)value);
        }
    }
}
