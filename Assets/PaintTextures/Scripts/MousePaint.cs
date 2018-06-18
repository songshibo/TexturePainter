using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MousePaint : MonoBehaviour {

	public Brush brush;

    PaintObject currentObject;
    VertexPaint vertexObject;

    void Update()
	{
		if(Input.GetMouseButton(0))
		{
			Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
			RaycastHit hitInfo;
			if(Physics.Raycast(ray, out hitInfo))
			{
				currentObject = hitInfo.transform.GetComponent<PaintObject>();
                vertexObject = hitInfo.transform.GetComponent<VertexPaint>();
				if(currentObject != null)
				{
					currentObject.Paint(hitInfo, brush);
				}
                else
                {
                    if(vertexObject != null)
                    {
                        vertexObject.PaintUV(hitInfo.textureCoord);
                    }
                }
			}
		}
	}
}
