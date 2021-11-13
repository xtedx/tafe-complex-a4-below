using System;
using System.IO;
using TeddyToolKit.Core;
using UnityEngine;
using UnityEngine.UI;
using Random = UnityEngine.Random;

namespace Game.Scripts
{
    public class GameManager : MonoSingleton<GameManager>
    {
        [SerializeField] public LogToFile logToFile;
        [SerializeField] public ObjectPool poolFish;
        [SerializeField] public ObjectPool poolShark;
        [SerializeField] public Transform poolParent;
        [SerializeField] public int sharkCount = 2;
        [SerializeField] public int fishCount = 8;

        [SerializeField] public GameObject guiCanvas;
        [SerializeField] public int score;
        [SerializeField] public Text textScore;
        [SerializeField] public Button buttonReset;
        [SerializeField] public Button buttonQuit;

        
        /// <summary>
        /// take the fish and put in pool with score
        /// </summary>
        /// <param name="fishGameObject"></param>
        /// <param name="isScore"></param>
        public void CaughtFish(GameObject fishGameObject, bool isScore = true)
        {
            var caughtName = fishGameObject.name;
            score++;
            if (caughtName.StartsWith("Shark"))
            {
                Debug.Log("Player caught a shark!");
                poolShark.Despawn(fishGameObject);
            } else if (caughtName.StartsWith("Fish"))
            {
                Debug.Log("Player caught a fish!");
                poolFish.Despawn(fishGameObject);
            }
            else
            {
                Debug.Log($"Caught mysterious fish {caughtName}");
            }

            UpdateGUI();
        }

        /// <summary>
        /// take all the fish in the lake and put in pool without scoring
        /// </summary>
        public void ResetGame()
        {
            var spawnAreaOffset = new Vector3(0, -6, 0);
            //clear the lake
            foreach (var fish in poolParent.GetComponentsInChildren<Transform>())
            {
                CaughtFish(fish.gameObject, false);
            }
            //add all fish from pool
            for (var i = 0; i < sharkCount; i++)
            {
                var f = poolShark.Spawn(poolParent);
                f.transform.position = (Random.insideUnitSphere * 6) + spawnAreaOffset;
                Debug.Log($"spawning shark {i}");
            } 
            for (var i = 0; i < fishCount; i++)
            {
                var f = poolFish.Spawn(poolParent);
                f.transform.position = (Random.insideUnitSphere * 6) + spawnAreaOffset;
                Debug.Log($"spawning  fish {i}");
            } 

            score = 0;
            UpdateGUI();
            poolParent.gameObject.SetActive(true);
        }

        private void UpdateGUI()
        {
            textScore.text = score.ToString("0000");
        }

        public void QuitGame()
        {
            Application.Quit();
        }

        private void Start()
        {
            guiCanvas.SetActive(true);
        }
    }
}