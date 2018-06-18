using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

[Serializable]
public class Brush
{
	public Texture BrushTexture;
	public Texture BrushNormalTexture;
	public float brushScale = 0.1f;
	public float normalBlend = 1f;
	public Color brushColor = Color.white;

}

[AddComponentMenu("CustomFunction/PaintObject")]
[RequireComponent(typeof(Renderer))]
[DisallowMultipleComponent]
public class PaintObject : MonoBehaviour {

	public bool UseMain = true;
	public bool UseNormal = true;
    public bool UseMetallic = false;
	Brush brush;

	[SerializeField]
    List<Painter> paintSet = new List<Painter>();

	static Material paintMainMaterial;
	static Material paintNormalMaterial;
    static Material paintMetallicMaterial;
	void Awake()
	{
		SetPaintMaterial();
		InitPropertyID();
		SetTexture();
		SetRender();
	}

    void SetPaintMaterial()
    {
        if (paintMainMaterial == null)
            paintMainMaterial = new Material(Resources.Load<Material>("Paint_Mat/PaintMainMat"));
        if (paintNormalMaterial == null)
            paintNormalMaterial = new Material(Resources.Load<Material>("Paint_Mat/PaintNormalMat"));

        Material[] mats = GetComponent<Renderer>().materials;
        for (int i = 0; i < mats.Length; ++i)
        {
            Painter p = new Painter(mats[i]);
            p.SetBoolParam(UseMain, UseNormal);
            paintSet.Add(p);
        }
    }

    void InitPropertyID()
    {
        foreach (Painter p in paintSet)
        {
            p.mainTexturePropertyID = Shader.PropertyToID(p.mainTextureName);
            p.normalTexturePropertyID = Shader.PropertyToID(p.normalTextureName);
        }
    }

	void SetTexture()
	{
		foreach (Painter p in paintSet)
		{
			if (p.material.HasProperty(p.mainTexturePropertyID))
				p.mainTexture = p.material.GetTexture(p.mainTexturePropertyID);
			if (p.material.HasProperty(p.normalTexturePropertyID))
				p.normalTexture = p.material.GetTexture(p.normalTexturePropertyID);
		}
	}

	RenderTexture SetRenderTexture(Texture baseTex, int PropertyID, Material material)
	{
		RenderTexture rt = new RenderTexture(baseTex.width, baseTex.height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear)
        {
            filterMode = baseTex.filterMode
        };
		Graphics.Blit(baseTex, rt);
		material.SetTexture(PropertyID, rt);
		return rt;
	}

	void SetRender()
	{
		foreach (Painter p in paintSet)
		{
			if (p.mainTexture!=null && p.UseMain)
				p.mainPaintTexture = SetRenderTexture(p.mainTexture, p.mainTexturePropertyID, p.material);
			if (p.normalTexture!=null && p.UseNormal)
				p.normalPaintTexture = SetRenderTexture(p.normalTexture, p.normalTexturePropertyID, p.material);
		}
	}

	/// <summary>
	/// Use given brush to paint the object
	/// </summary>
	/// <param name="hitInfo">ray hit information, used to get texcoord</param>
	/// <param name="brush">input brush</param>
	public void Paint(RaycastHit hitInfo, Brush brush)
	{
		this.brush = brush;
		if (hitInfo.collider is MeshCollider)
		{
			PaintUV(hitInfo.textureCoord);
		}
	}


	/// <summary>
	/// Use self brush to paint object
	/// </summary>
	/// <param name="hitInfo">ray hit infomation</param>
	public void Paint(RaycastHit hitInfo)
	{
		if (hitInfo.collider is MeshCollider)
		{
			PaintUV(hitInfo.textureCoord);
		}
	}

	void SetPaintMainData(Vector2 uv)
	{
		paintMainMaterial.SetVector(Shader.PropertyToID("_PaintUV"), uv);
		paintMainMaterial.SetTexture(Shader.PropertyToID("_Brush"), brush.BrushTexture);
		paintMainMaterial.SetFloat(Shader.PropertyToID("_BrushScale"), brush.brushScale);
		paintMainMaterial.SetColor(Shader.PropertyToID("_ControlColor"), brush.brushColor);
	}

	void SetPaintNormalData(Vector2 uv)
	{
		paintNormalMaterial.SetVector(Shader.PropertyToID("_PaintUV"), uv);
		paintNormalMaterial.SetTexture(Shader.PropertyToID("_Brush"), brush.BrushTexture);
		paintNormalMaterial.SetFloat(Shader.PropertyToID("_BrushScale"), brush.brushScale);
		paintNormalMaterial.SetFloat(Shader.PropertyToID("_NormalBlend"), brush.normalBlend);
		paintNormalMaterial.SetTexture(Shader.PropertyToID("_BrushNormal"), brush.BrushNormalTexture);
	}

	private void PaintUV(Vector2 uv)
	{
		foreach (Painter p in paintSet)
		{
			if(p.UseMain && p.mainPaintTexture != null)
			{
				RenderTexture mainPaintTextureBuffer = RenderTexture.GetTemporary(p.mainPaintTexture.width, p.mainPaintTexture.height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
				SetPaintMainData(uv);
				Graphics.Blit(p.mainPaintTexture, mainPaintTextureBuffer, paintMainMaterial);
				Graphics.Blit(mainPaintTextureBuffer, p.mainPaintTexture);
				RenderTexture.ReleaseTemporary(mainPaintTextureBuffer);
			}
			
			if(p.UseNormal && p.normalPaintTexture != null)
			{
				RenderTexture normalPaintTextureBuffer = RenderTexture.GetTemporary(p.normalPaintTexture.width, p.normalPaintTexture.height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
				SetPaintNormalData(uv);
				Graphics.Blit(p.normalPaintTexture, normalPaintTextureBuffer, paintNormalMaterial);
				Graphics.Blit(normalPaintTextureBuffer, p.normalPaintTexture);
				RenderTexture.ReleaseTemporary(normalPaintTextureBuffer);
			}
		}
	}
}
