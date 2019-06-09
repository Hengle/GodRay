using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class Volumelight_1 : MonoBehaviour
{
    public bool blurtype;
    public Material Volumelight;
    public Color StepColor;
    [Range(1,100)]
    public float Depthfloor;
    [Range(10, 1000)]
    public float Depthupper;
    public Camera thiscamera;
    [Range(0.01f,.5f)]
    public float LightDirx;
    [Range(0.01f, .5f)]
    public float LightDiry;
    private Vector4 LightPos;
    public Transform lighttrans;
    [Range(0.5f,3.0f)]
    public float Blurtimes;
    [Range(0.01f,2f)]
    public float LightIntencity;
    [Range(1,20)]
    public float Level;
    private float LightDirx_2;
    private float LightDiry_2;
    public Color _LightCol;
    private void OnEnable()
    {
        thiscamera = this.GetComponent<Camera>();
        thiscamera.depthTextureMode |= DepthTextureMode.Depth;
    }
    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture source, RenderTexture dest)
    {
        RenderTexture midpic = RenderTexture.GetTemporary(source.width, source.height, 0);
        RenderTexture midpic2 = RenderTexture.GetTemporary(source.width, source.height, 0);
        Volumelight.SetColor("_StepColor", StepColor);
        Volumelight.SetFloat("_Depthupper", Depthupper);
        Volumelight.SetFloat("_Depthfloor", Depthfloor);
        Graphics.Blit(source, midpic, Volumelight, 0);
        LightPos = thiscamera.WorldToViewportPoint(lighttrans.transform.position);
        Volumelight.SetVector("_LightPos", LightPos);
        //Volumelight.SetFloat("_LightIntencity", LightIntencity);
        Volumelight.SetFloat("_Level", Level);
        Volumelight.SetVector("_LightDir", new Vector4(LightDirx,LightDiry,0,0));
        if (blurtype)
        {
            for (int i = 0; i < Blurtimes; i++)
            {
                LightDirx_2 = LightDirx * (i * 2 + 2);
                LightDiry_2 = LightDiry * (i * 2 + 2);
                Graphics.Blit(midpic, midpic2, Volumelight, 1);
                LightDirx_2 = LightDirx * (i * 2 + 6);
                LightDiry_2 = LightDiry * (i * 2 + 6);
                Graphics.Blit(midpic2, midpic, Volumelight, 1);
            }
        }
        else
        {
            Graphics.Blit(midpic, midpic2, Volumelight, 2);
            Graphics.Blit(midpic2, midpic, Volumelight, 2);
        }
        Volumelight.SetFloat("_LightIntencity", LightIntencity);
        Volumelight.SetTexture("_BlurTex", midpic);
        Volumelight.SetColor("_LightCol", _LightCol);
        Graphics.Blit(source, dest, Volumelight, 3);
        RenderTexture.ReleaseTemporary(midpic);
        RenderTexture.ReleaseTemporary(midpic2);

    }
}