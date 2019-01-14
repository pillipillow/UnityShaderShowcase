using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class TangentSpaceVisual : MonoBehaviour
{
    public enum VisualType
    {
        NONE,
        NORMAL,
        TANGENT,
        BINORMAL,
        ALL 
    };

    public VisualType visualType = VisualType.ALL;

    bool isTangent = true;
    bool isNormal = true;
    bool isBinormal =  true;

    public float offset = 0.01f;
    public float scale = 0.1f;

    void OnDrawGizmos()
    {
        MeshFilter filter = GetComponent<MeshFilter>();
        if (filter)
        {
            Mesh mesh = filter.sharedMesh;
            if (mesh)
            {
                ShowTangentSpace(mesh);
            }
        }
    }

    void ShowTangentSpace(Mesh mesh)
    {
        Vector3[] vertices = mesh.vertices;
        Vector3[] normals = mesh.normals;
        Vector4[] tangents = mesh.tangents;
        for (int i = 0; i < vertices.Length; i++)
        {
            DrawTangentSpace(
                transform.TransformPoint(vertices[i]),
                transform.TransformDirection(normals[i]),
                transform.TransformDirection(tangents[i]),
				tangents[i].w
            );
        }

    }

    void DrawTangentSpace(Vector3 vertex, Vector3 normal, Vector3 tangent, float binormalSign)
    {
        vertex += normal * offset;
        if(isNormal)
        {
            Gizmos.color = Color.green;
            Gizmos.DrawLine(vertex, vertex + normal * scale);
        }

        if(isTangent)
        {
            Gizmos.color = Color.red;
            Gizmos.DrawLine(vertex, vertex + tangent * scale);
        }
       
        if(isBinormal)
        {
            Vector3 binormal = Vector3.Cross(normal, tangent) * binormalSign;
            Gizmos.color = Color.blue;
            Gizmos.DrawLine(vertex, vertex + binormal * scale);
        }
      
    }

    void Update()
    {
        if(visualType == VisualType.ALL)
        {
            isNormal = true;
            isTangent = true;
            isBinormal = true;
        }
        else if(visualType == VisualType.BINORMAL)
        {
            isNormal = false;
            isTangent = false;
            isBinormal = true;
        }
        else if(visualType == VisualType.NORMAL)
        {
            isNormal = true;
            isTangent = false;
            isBinormal = false;
        }
        else if(visualType == VisualType.TANGENT)
        {
            isNormal = false;
            isTangent = true;
            isBinormal = false;
        }
        else
        {
            isNormal = false;
            isTangent = false;
            isBinormal = false;
        }
    }
}
