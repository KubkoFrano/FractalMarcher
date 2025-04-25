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
    }

    private void Start()
    {
        slider.onValueChanged.AddListener(UpdateText);
        onValueChanged = slider.onValueChanged;
        UpdateText(slider.value);
    }

    public void UpdateText(float value)
    {
        text.text = value.ToString();
    }

    public void SetValue(float value)
    {
        Debug.Log(gameObject.name + " " + slider);
        slider.value = value;
        text.text = value.ToString();
    }
}
