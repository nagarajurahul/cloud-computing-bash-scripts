# Chapter 01 - Designing for a Distributed World


1. What is distributed computing?

Distributed computing refers to system where different components of a program or system run on multiple machines that communicate and coordinate with each other over a network. 

These systems appear as a single, cohesive entity to the user, even though the computing tasks are distributed across different physical machines.

For example: Backend servers, Frontend servers and Database servers

---

2. Describe the three major composition patterns in distributed computing.

`Client-Server Model`: Here clients send requests to a server, which processes them and sends back a response. The server is the provider of resources or services.
Example: A web browser (client) sends requests to a web server, which serves the content (web pages).

`Peer-to-Peer (P2P) Model`:Every participant (node) can act as both a client and a server. This decentralized approach allows for more flexibility and better scalability.
Example: File-sharing systems like BitTorrent.

`Publish-Subscribe Model`: A message broker receives messages from publishers and forwards them to subscribers who have expressed interest in receiving such messages.
Example: Message queues like Amazon SNS (Simple Notification Service), where different services subscribe to topics to receive updates.

---

3. What are the three patterns discussed for storing state?

`Stateful Servers`: The server keeps track of the state of interactions, often stored in memory or databases. The state is maintained across requests from the client.
Example: Web applications with user sessions.

`Stateless Servers`: The server does not retain any information about previous interactions. Each request is treated independently, and all state information must be included in the request.
Example: RESTful APIs, where each request contains all necessary information to process it.

`Distributed State Storage`: The state is distributed across multiple systems or nodes. This approach is used to scale applications by storing state in systems like distributed databases or file systems.
Example: A distributed database like Apache Cassandra or Amazon DynamoDB.

---


4. Sometimes a master server does not reply with an answer but instead replies with where the answer can be found. What are the benefits of this method?

When a master server does not provide the actual answer but tells the client where to find it, this method is known as delegation.

Benefits include

`Scalability` - Load on the master server is reduced because it does not need to process every request.

`Efficiency`: By directing requests to the relevant data storage or computation nodes, it can reduce unnecessary delays and network traffic, especially in large-scale systems.

`Decentralization`: It helps in avoiding a SPOF - single point of failure since the work is distributed to different servers or locations.

---

5. Section 1.4 describes a distributed file system, including an example of how reading terabytes of data would work. How would writing terabytes of data work?

In a distributed file system (DFS), writing terabytes of data would be handled by breaking the data into smaller chunks (blocks) and storing them across different nodes in the system.

`Chunking`: Large files are split into fixed-size blocks (often 64MB or 128MB in DFS like HDFS).

`Replication`: To ensure data reliability, these chunks are typically replicated across multiple nodes. For example, each chunk may be stored on three different nodes (replication factor of 3).

`Writing Data`: The system writes each chunk to the corresponding nodes. This parallelism allows for handling massive amounts of data efficiently.

`Consistency`: Once all chunks are written, the DFS ensures that the data is consistent across the nodes.

---


6. Explain each component of the CAP Principle. (If you think the CAP Principle is awesome, read “The Part-Time Parliament” (Lamport & Marzullo 1998) and “Paxos Made Simple” (Lamport 2001).)

The CAP theorem states that a distributed system can only guarantee two out of these three properties at a time. For example, a system can be CP (Consistency and Partition Tolerance) or AP (Availability and Partition Tolerance), but not all three simultaneously.

The CAP Principle refers to the trade-offs that distributed systems face when dealing with consistency, availability, and partition tolerance:

`Consistency`: Every read request will return the most recent write (or an error). This means that all nodes in the system have the same data at any given time.

`Availability`: Every request (read or write) will receive a response, even if some of the nodes are down. The system is available to handle requests all the time.

`Partition Tolerance`: The system can continue to function even if network partitions (communication breakdowns between nodes) occur. It ensures that the system does not stop even if some nodes cannot communicate with others.

---

7. What does it mean when a system is loosely coupled? What is the advantage of these systems?

A loosely coupled system refers to a system where individual components or services operate independently of each other. The components communicate with each other through well-defined interfaces, often over a network. This allows each component to change or fail without significantly affecting the rest of the system.

Benefits:
`Scalability`: Components can be scaled independently based on the demand, making the system more flexible.

`Fault Tolerance`: A failure in one component does not necessarily cause a failure in the entire system.

`Flexibility`: Services can be updated, replaced, or deployed independently without impacting other parts of the system.

---

8. How do we estimate how fast a system will be able to process a request such as retrieving an email message?

There are many ways, but we can generally estimate through

`Network Latency`: The time it takes for the request to travel from the client to the server.

`Server Processing Time`: The time it takes for the server to process the request, retrieve the email from the database, and send it back.

`Database Query Time`: The time spent querying the email storage system (e.g., retrieving data from a relational database or NoSQL database).

`Caching`: If caching is used, previously requested emails may be retrieved faster.

`Load`: The system's load and the number of concurrent requests it is handling.

---

9. In Section 1.7 three design ideas are presented for how to process email deletion requests. Estimate how long the request will take for deleting an email message for each of the three?  Use the updated numbers from the book located at: [Numbers Every Developer Needs to know](https://colin-scott.github.io/personal_website/research/interactive_latency.html "Link to numbers every developer needs to know") - update of Figure 1.10 in the book. SHOW WORK!

---

### Three Design Ideas for Email Deletion

#### 1. Direct Deletion

- Network Time: 0.5 ms (round trip)
- Authentication: 3 ms
- Disk Seek & Read: 90 ms (3 seeks × 10 ms, 2 MB read = 60 ms)
- Index Update: 30 ms
- Total: 123.5 ms

#### 2. Marking as Deleted in the Index

- Network Time: 0.5 ms
- Authentication: 3 ms
- Disk Seek: 30 ms (3 seeks × 10 ms)
- Index Update: 10 ms
- Total: 43.5 ms

#### 3. Asynchronous Design

- Network Time: 0.5 ms
- Authentication: 3 ms
- Queueing: 1 ms
- Total: 4.5 ms

#### Summary

- Direct Deletion: 123.5 ms
- Marking as Deleted: 43.5 ms
- Asynchronous Design: 4.5 ms

#### Conclusion

- The Asynchronous Design is the fastest, followed by Marking as Deleted in the Index, with Direct Deletion being the slowest.
