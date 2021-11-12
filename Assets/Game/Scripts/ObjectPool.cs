using System;
using System.Collections.Generic;
using UnityEngine;

namespace Game.Scripts
{
    /// <summary>
    /// object pooling design pattern,
    /// </summary>
    public class ObjectPool : MonoBehaviour
    {
        public GameObject prefab;
        private Stack<GameObject> objects;

        private void Awake()
        {
            objects = new Stack<GameObject>();
            if (prefab == null)
            {
                Debug.LogError($"this pool {gameObject.name} does not have a prefab, please drag one to the inspector");
            }
        }

        /// <summary>
        /// get object from pool, or instantiate new if empty
        /// </summary>
        /// <param name="parent"></param>
        /// <returns></returns>
        public GameObject Spawn(Transform parent)
        {
            try
            {
                GameObject spawned = objects.Pop();
                spawned.transform.parent = parent;
                spawned.transform.position = prefab.transform.position;
                spawned.transform.rotation = prefab.transform.rotation;
                spawned.transform.localScale = prefab.transform.localScale;

                spawned.gameObject.SetActive(true);
                return spawned;
            }
            //stack is empty
            catch (InvalidOperationException e)
            {
                return Instantiate(prefab, parent);
            }
        }

        /// <summary>
        /// deactivate and store in the pool
        /// </summary>
        /// <param name="spawned"></param>
        public void Despawn(GameObject spawned)
        {
            spawned.SetActive(false);
            spawned.transform.parent = transform.parent;
            objects.Push(spawned);
        }
    }
}