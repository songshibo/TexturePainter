using UnityEngine;

public class VertexPaint : MonoBehaviour {

	public enum Channel{
		red,
		green,
		blue
	}
	public Texture brush;
    [Range(0,1)]
    public float strength = 0.5f;
	public float scale;
	public Channel channel;
	public string controlTextureName = "_ControlMap";

	Texture controlTexture;
	RenderTexture paintControlTexture;
	int controlPropertyID;
	static Material paintMainMaterial;


	Material material;
	
	void Awake()
	{
		if (paintMainMaterial == null)
            paintMainMaterial = new Material(Resources.Load<Material>("Paint_Mat/PaintVertexMat"));
		controlPropertyID = Shader.PropertyToID(controlTextureName);
		material = GetComponent<Renderer>().material;
		controlTexture = material.GetTexture(controlPropertyID);
		if (controlTexture == null)
		{
			controlTexture = new Texture2D(1024, 1024, TextureFormat.ARGB32, false, true);
		}
		paintControlTexture = SetRenderTexture(controlTexture, controlPropertyID, material);
	}

	//void Update()
	//{
	//	if(Input.GetMouseButton(0))
	//	{
	//		Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
	//		RaycastHit hitInfo;
	//		if(Physics.Raycast(ray, out hitInfo))
	//		{
	//			if (hitInfo.transform.gameObject == gameObject && (hitInfo.collider is MeshCollider))
	//			{
	//				PaintUV(hitInfo.textureCoord);
	//			}
	//		}
	//	}
	//}

    public void PaintUV(Vector2 uv)
	{
		RenderTexture mainPaintTextureBuffer = RenderTexture.GetTemporary(paintControlTexture.width, paintControlTexture.height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
		SetPaintMainData(uv);
		Graphics.Blit(paintControlTexture, mainPaintTextureBuffer, paintMainMaterial);
		Graphics.Blit(mainPaintTextureBuffer, paintControlTexture);
		RenderTexture.ReleaseTemporary(mainPaintTextureBuffer);
	}

	RenderTexture SetRenderTexture(Texture baseTex, int PropertyID, Material mat)
	{
		RenderTexture rt = new RenderTexture(baseTex.width, baseTex.height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear)
        {
            filterMode = baseTex.filterMode
        };
		Graphics.Blit(baseTex, rt);
		mat.SetTexture(PropertyID, rt);
		return rt;
	}

	void SetPaintMainData(Vector2 uv)
	{
		Color color;
		switch (channel)
		{
			case Channel.red:
                color = new Color(strength,0,0,1);
				break;
			case Channel.green:
                color = new Color(0,strength,0,1);
				break;
			case Channel.blue:
                color = new Color(0,0,strength,1);
				break;
			default:
				color = new Color(0,0,0,1);
				break;
		}
		paintMainMaterial.SetVector(Shader.PropertyToID("_PaintUV"), uv);
		paintMainMaterial.SetTexture(Shader.PropertyToID("_Brush"), brush);
		paintMainMaterial.SetFloat(Shader.PropertyToID("_BrushScale"), scale);
        paintMainMaterial.SetColor(Shader.PropertyToID("_ControlColor"), color);
	}
}
