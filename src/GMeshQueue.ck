// name: queue.ck
// ===============
// author: Ethan Buck
// date: 11/27/23
//
// desc: very basic implementation of queue data structure (very easy with ChucK arrays haha)
//
// note 1: I do not know how to return null in chuck, so if dequeue() or peek() is called on an 
// empty array, then the dummy_return value is returned.
// 
// note 2: you have to manually change the types (e.g. replace all int declarations with whatever
// type you want, except for the front and rear pointers!!) for whatever type you are using :(
public class GMeshQueue {
    GMesh queue[0];
    0 => int front => int rear;     // don't change these types!!
    GMesh dummy_return;   // returns if dequeue() or peek() called on an empty queue

    fun int isEmpty() {
        return queue.size() == 0;
    }

    // insert element to rear of queue
    fun void enqueue(GMesh @x) {
        if (this.isEmpty()) {   // queue is empty, so initialize pointers
            queue << x;
        } else {
            1 +=> rear;
            queue << x;
        }
    }

    fun GMesh dequeue() {
        if (this.isEmpty()) {
            <<< "queue is empty, nothing to dequeue" >>>;
            return dummy_return;
        } else {
            1 -=> rear;
            queue[0] @=> GMesh output;
            queue.popOut(0);
            return output;
        }
    }

    fun GMesh peek() {
        if (this.isEmpty()) {
            <<< "queue is empty, nothing to peek" >>>;
            return dummy_return;
        } else {
            return queue[0];
        }
    }

    fun int size() {
        return queue.size();
    }

    fun void display() {
        if (this.isEmpty()) {
            <<< "queue is empty, nothing to display" >>>;
        } else {
            for (0 => int i; i < queue.size(); 1 +=> i) {
                <<<"queue[", i, "] = ", queue[i] >>>; 
            }
        }
    }
}