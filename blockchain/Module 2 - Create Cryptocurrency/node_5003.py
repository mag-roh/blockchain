# Module-2 : create cryptocurrency

# installations required:
# flask==0.12.2
# postman HTTP client
# requests==2.18.4

# importing Libraries

import datetime
import hashlib
import json
from flask import Flask, jsonify,request
import requests
from uuid import uuid4 #to generate a random unique address for the node
from urllib.parse import urlparse 
#part 1-building the blockchain

class Blockchain:
    
    def __init__(self):
        self.chain = []
        self.transactions = [] # initialising before the breate block function as the transactions should be present before creation of the block otherwise it would give an error
        self.create_block(proof = 1, previous_hash = '0') 
        self.nodes = set()
     
    def create_block(self, proof, previous_hash):
        block = {'index': len(self.chain)+1,
                 'timestamp': str(datetime.datetime.now()),
                 'proof': proof,
                 'previous_hash':  previous_hash, 
                 'transactions': self.transactions }
        self.transactions = []
        self.chain.append(block)
        return block
    
    def get_previous_block(self):
        return self.chain[-1]
    
    def proof_of_work(self, previous_proof):
        new_proof = 1
        check_proof = False
        while check_proof is False:
            hash_operation = hashlib.sha256(str(new_proof**2 - previous_proof**2).encode()).hexdigest()
            if hash_operation[:4] =='0000':
                check_proof=True
            else:
                new_proof += 1
        return new_proof      
    
    def hash(self, block):
        encoded_block = json.dumps(block, sort_keys = True).encode()
        return hashlib.sha256(encoded_block).hexdigest()
    def is_chain_valid(self, chain):
        previous_block = chain[0]
        block_index = 1
        while block_index < len(chain):
            block = chain[block_index]
            if block['previous_hash'] != self.hash(previous_block):
                return False
            previous_proof = previous_block['proof']
            proof = block['proof']
            hash_operation = hashlib.sha256(str(proof**2 - previous_proof**2).encode()).hexdigest()
            if hash_operation[:4] !='0000':
                return False
            previous_block = block
            
            block_index += 1
        return True
    def add_transaction(self, sender, receiver, amount):
        self.transactions.append({'sender':sender,
                                  'receiver':receiver,
                                  'amount':amount})
        previous_block = self.get_previous_block()
        return previous_block['index']+1
    
    def add_node(self, address):
        parsed_url = urlparse(address)
        self.nodes.add(parsed_url.netloc)
       
    def replace_chain(self):
        network = self.nodes
        longest_chain = None
        max_length = len(self.chain)
        for node in network:
            response = requests.get(f'http://{node}/get_chain') #to get the chain length at each node whihc starts from 192.168.1.17:5000 using the /get_chain method starting from port 5000
            if response.status_code == 200:
               length = response.json()[ 'length' ] #gets the element of the json response with the key name as length
               chain = response.json()[ 'chain' ] #to get the chain from the json response
               if length > max_length and self.is_chain_valid(chain):
                   max_length = length
                   longest_chain = chain
        if longest_chain:
            self.chain = longest_chain
            return True
        return False
# Part-2 Mining our blockchain

#creating a web app
app = Flask(__name__) 
# Creating an address for the node on port 5000
node_address = str(uuid4()).replace('-','')
# creating a blockchain

blockchain = Blockchain()

# Mining a new block

@app.route('/mine_block', methods=['GET'])
def mine_block():
    previous_block = blockchain.get_previous_block()
    previous_proof = previous_block['proof']
    proof = blockchain.proof_of_work(previous_proof)
    previous_hash = blockchain.hash(previous_block)
    blockchain.add_transaction(sender = node_address, receiver ='You', amount = 1000)
    block = blockchain.create_block(proof, previous_hash)
    response = {'message': 'Congratulations, you just mined a block',
                'index' : block['index'],
                'timestamp' : block['timestamp'],
                'proof' : block['proof'],
                'previous_hash' : block['previous_hash'],
                'transactions': block['transactions']}
    return jsonify(response), 200 

#Getting the full blockchain
@app.route('/get_chain', methods=['GET'])
def get_chain():
    response = {'chain' : blockchain.chain,
                'length' : len(blockchain.chain)}
    return jsonify(response), 200 

# Checking if the blockchain is valid

@app.route('/is_valid', methods=['GET'])
def is_valid():
    is_valid = blockchain.is_chain_valid(blockchain.chain)
    if is_valid:
        response = {'message':'All good. Blockchain is valid.'}
    else:
        response = {'message':'Houstan, we have a problem. Blockchain is not valid.'}
    return jsonify(response), 200 

#adding a new transaction to the blockchain

@app.route('/add_transaction', methods=['POST'])
def add_transaction():
    json = request.get_json()
    transaction_keys = ['sender', 'receiver', 'amount']
    if not all (key in json for key in transaction_keys): #if all the keys in the transaction_keys list are not present in json 
        return 'Some elements of the transaction are missing' , 400
    index = blockchain.add_transaction(json['sender'], json['receiver'], json['amount'])
    response = {'message': f'This transaction will be added to block {index}'}
    return jsonify(response), 201

# part-3 : decentralizing our blockchain(to mine blocks on any of the nodes)

# connecting new nodes
@app.route('/connect_node', methods=['POST'])
def connect_node():
    json = request.get_json() #contains address of all the nodes in the network, to add a new node the address of the new node is sent first to add it into the node network
    nodes = json.get('nodes')
    if nodes is None:
        return "No Node", 400
    for node in nodes:
        blockchain.add_node(node)
    response = {'message': 'All the nodes are now connected. The RohCoin blockchain now contains the following nodes: ',
                'total_nodes': list(blockchain.nodes)}
    return jsonify(response), 201

# replacing the chain by the longest chain if needed(get request)

@app.route('/replace_chain', methods=['GET'])
def replace_chain():
    is_chain_replaced = blockchain.replace_chain()
    if is_chain_replaced:
        response = {'message':'The nodes had different chains so the chain was replaced by the longest chain.',
                    'new_chain': blockchain.chain}
    else:
        response = {'message':'All good. The chain is the longest one.',
                    'actual_chain': blockchain.chain}
    return jsonify(response), 200 
# Running the app

app.run(host = '0.0.0.0', port = 5003)

# we will create 2 json files one with the address of all the nodes as a get request and one with the details about the sender, receiver and the amount information as a post request
# we will create 3 python files one for me (5001), for priyansh (5002) and for you (5003)