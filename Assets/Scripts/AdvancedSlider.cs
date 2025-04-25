using TMPro;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

public class AdvancedSlider : MonoBehaviour
{
    private Slider slider;
    private TextMeshProUGUI text;

    [HideInInspector]
    public UnityEvent<float> onValueChanged;

    private void Awake()
    {
        slider = GetComponentInChildren<Slider>();
        text = GetComponentInChildren<TextMeshProUGUI>();
        onValueChanged = slider.onValueChanged;
        slider.onValueChanged.AddListener(UpdateText);
    }

    private void Start()
    {
        UpdateText(slider.value);
    }

    public void UpdateText(float value)
    {
        text.text = value.ToString();
    }

    public void SetValue(float value)
    {
        slider.value = value;
        text.text = value.ToString();
    }
}
