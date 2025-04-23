using TMPro;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

public class AdvancedSlider : MonoBehaviour
{
    private Slider slider;
    private TextMeshProUGUI text;

    private void Start()
    {
        slider = GetComponentInChildren<Slider>();
        text = GetComponentInChildren<TextMeshProUGUI>();
        slider.onValueChanged.AddListener(UpdateText);
        UpdateText(slider.value);
    }

    public void UpdateText(float value)
    {
        text.text = value.ToString();
    }
}
