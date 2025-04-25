using UnityEngine;
using System.Collections.Generic;
using TMPro;
using UnityEngine.UI;

public class SettingsPanel : MonoBehaviour
{
    private Settings settings;

    [Header("Fractal specific settings")]
    [SerializeField] private List<GameObject> mandelbulbSettings;
    [SerializeField] private List<GameObject> juliaSettings;

    [Header("General settings")]
    [SerializeField] private TMP_Dropdown fractalDropdown;
    [SerializeField] private TMP_InputField maxStepsInput;
    [SerializeField] private TMP_InputField epsilonMinInput;
    [SerializeField] private TMP_InputField epsilonMaxInput;
    [SerializeField] private AdvancedSlider colorMultiplierSlider;
    [SerializeField] private TMP_InputField iterationsInput;
    [SerializeField] private TMP_InputField powerInput;
    [SerializeField] private AdvancedSlider seedXSlider;
    [SerializeField] private AdvancedSlider seedYSlider;
    [SerializeField] private AdvancedSlider seedZSlider;
    [SerializeField] private AdvancedSlider seedWSlider;
    [SerializeField] private AdvancedSlider parSlider;

    private void Awake()
    {
        settings = Settings.GetInstance();
    }

    private void Start()
    {
        AssignListeners();
        LoadValues();

        SelectFractal(fractalDropdown.value);
        Resume();
    }

    public void Pause()
    {
        gameObject.SetActive(true);
    }

    public void Resume()
    {
        gameObject.SetActive(false);
    }

    public void SelectFractal(int fractal)
    {
        if (fractal == (int)Enums.Fractal.Mandelbulb)
        {
            SetFractal(Enums.Fractal.Mandelbulb);
            UnsetFractal(Enums.Fractal.QuaternionJuliaSet);
        }
        else if (fractal == (int)Enums.Fractal.QuaternionJuliaSet)
        {
            SetFractal(Enums.Fractal.QuaternionJuliaSet);
            UnsetFractal(Enums.Fractal.Mandelbulb);
        }
    }

    private void SetFractal(Enums.Fractal fractal)
    {
        List<GameObject> specificSettings = fractal == Enums.Fractal.Mandelbulb ? mandelbulbSettings : juliaSettings;

        foreach (var sett in specificSettings)
        {
            sett.SetActive(true);
        }
    }

    private void UnsetFractal(Enums.Fractal fractal)
    {
        List<GameObject> specificSettings = fractal == Enums.Fractal.Mandelbulb ? mandelbulbSettings : juliaSettings;

        foreach (var sett in specificSettings)
        {
            sett.SetActive(false);
        }
    }

    private void AssignListeners()
    {
        //Ray marching
        maxStepsInput.onValueChanged.AddListener(value => { if (!string.IsNullOrEmpty(value)) settings.maxSteps = int.Parse(value); });

        //Epsilon
        epsilonMinInput.onValueChanged.AddListener(value => {if (!string.IsNullOrEmpty(value)) settings.epsilonMin = float.Parse(value); });
        epsilonMaxInput.onValueChanged.AddListener(value => {if (!string.IsNullOrEmpty(value)) settings.epsilonMax = float.Parse(value); });

        //Lighting
        colorMultiplierSlider.onValueChanged.AddListener(value => { settings.colorMultiplier = value; });

        //Mandelbulb
        iterationsInput.onValueChanged.AddListener(value => {if (!string.IsNullOrEmpty(value)) settings.iterations = int.Parse(value); });
        powerInput.onValueChanged.AddListener(value => {if (!string.IsNullOrEmpty(value)) settings.power = int.Parse(value); });

        //Julia
        seedXSlider.onValueChanged.AddListener(value => {settings.seedX = value; Debug.Log("set x " + value); });
        seedYSlider.onValueChanged.AddListener(value => {settings.seedY = value; });
        seedZSlider.onValueChanged.AddListener(value => {settings.seedZ = value; });
        seedWSlider.onValueChanged.AddListener(value => {settings.seedW = value; });
        parSlider.onValueChanged.AddListener(value => {settings.par = value; });

        //Fractal
        fractalDropdown.onValueChanged.AddListener(value => { settings.fractal = (Enums.Fractal)value; });
    }

    private void LoadValues()
    {
        //Ray marching
        maxStepsInput.text = settings.maxSteps.ToString();

        //Epsilon
        epsilonMinInput.text = settings.epsilonMin.ToString();
        epsilonMaxInput.text = settings.epsilonMax.ToString();

        //Lighting
        colorMultiplierSlider.SetValue(settings.colorMultiplier);

        //Mandelbulb
        iterationsInput.text = settings.iterations.ToString();
        powerInput.text = settings.power.ToString();

        //Julia
        seedXSlider.SetValue(settings.seedX);
        seedYSlider.SetValue(settings.seedY);
        seedZSlider.SetValue(settings.seedZ);
        seedWSlider.SetValue(settings.seedW);
        parSlider.SetValue(settings.par);

        //Fractal
        fractalDropdown.value = (int)settings.fractal;
    }
}
