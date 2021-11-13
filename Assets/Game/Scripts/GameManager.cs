using TeddyToolKit.Core;
using UnityEngine;

namespace Game.Scripts
{
    public class GameManager : MonoSingleton<GameManager>
    {
        [SerializeField] public LogToFile logToFile;
        [SerializeField] public ObjectPool poolFish;
        [SerializeField] public ObjectPool poolShark;
        [SerializeField] public Transform poolParent;
        [SerializeField] public int score;


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
        }

        /// <summary>
        /// take all the fish in the lake and put in pool without scoring
        /// </summary>
        public void ResetGame()
        {
            foreach (var fish in poolParent.GetComponentsInChildren<Transform>())
            {
                CaughtFish(fish.gameObject, false);
            }
        }
    }
}