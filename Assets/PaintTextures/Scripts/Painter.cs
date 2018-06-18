using UnityEngine;

public class Painter {

	public string mainTextureName = "_MainTex";
	public string normalTextureName = "_BumpMap";
	public bool UseMain = true;
	public bool UseNormal = true;

	[HideInInspector]
	public Material material;

	[HideInInspector]
	public int mainTexturePropertyID;
	[HideInInspector]
	public int normalTexturePropertyID;
    [HideInInspector]
    public int metallicTexturePropertyID;
	[HideInInspector]
	public Texture mainTexture;
	[HideInInspector]
	public RenderTexture mainPaintTexture;
	[HideInInspector]
	public Texture normalTexture;
	[HideInInspector]
	public RenderTexture normalPaintTexture;
	[HideInInspector]
	public Texture heightTexture;
	[HideInInspector]
	public RenderTexture heightPaintTexture;

	
	public Painter() {}

	public Painter(Material mat)
	{
		material = mat;
	}

	public Painter(string mainName, string normalName)
	{
		mainTextureName = mainName;
		normalTextureName = normalName;
	}

	public void SetBoolParam(bool _main, bool _normal)
	{
		UseMain = _main;
		UseNormal = _normal;
	}
}
