using UnityEngine;
using System.Collections.Generic;
using TMPro;

public class Settings : MonoBehaviour
{
    [Header("Fractal specific settings")]
    [SerializeField] private List<GameObject> mandelbulbSettings;
    [SerializeField] private List<GameObject> juliaSettings;

    [Header("General settings")]
    [SerializeField] private TMP_Dropdown fractalDropdown;

    private void Start()
    {
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
}
