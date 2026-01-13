#!/usr/bin/env python3
"""
Test script for AWS Bedrock Agent
Tests the deployed agent using boto3 SDK
"""

import boto3
import json
import sys
import os
from datetime import datetime

# Configuration
AGENT_ID = "NVWOHTF4ZZ"
AGENT_ALIAS_ID = "YIQDRAV17J"
AWS_REGION = "us-east-1"
# Use bedrock-test profile if AWS_PROFILE not set
AWS_PROFILE = os.environ.get('AWS_PROFILE', 'bedrock-test')

def test_agent_invocation(query_text):
    """
    Invoke the Bedrock Agent with a query
    
    Args:
        query_text: The question or command to send to the agent
    """
    print(f"\n{'='*80}")
    print(f"Testing Bedrock Agent: {AGENT_ID}")
    print(f"Agent Alias: {AGENT_ALIAS_ID}")
    print(f"Region: {AWS_REGION}")
    print(f"AWS Profile: {AWS_PROFILE}")
    print(f"{'='*80}\n")
    
    try:
        # Initialize boto3 session with profile
        session = boto3.Session(profile_name=AWS_PROFILE, region_name=AWS_REGION)
        
        # Initialize Bedrock Agent Runtime client
        client = session.client('bedrock-agent-runtime')
        
        # Check current credentials
        sts = session.client('sts')
        identity = sts.get_caller_identity()
        print(f"Using AWS Identity: {identity['Arn']}\n")
        
        # Generate unique session ID
        session_id = f"test-session-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
        
        print(f"Query: {query_text}")
        print(f"Session ID: {session_id}\n")
        print("Agent Response:")
        print("-" * 80)
        
        # Invoke the agent
        response = client.invoke_agent(
            agentId=AGENT_ID,
            agentAliasId=AGENT_ALIAS_ID,
            sessionId=session_id,
            inputText=query_text
        )
        
        # Process streaming response
        completion_text = ""
        event_stream = response.get('completion', [])
        
        for event in event_stream:
            if 'chunk' in event:
                chunk = event['chunk']
                if 'bytes' in chunk:
                    chunk_text = chunk['bytes'].decode('utf-8')
                    completion_text += chunk_text
                    print(chunk_text, end='', flush=True)
        
        print("\n" + "-" * 80)
        
        # Display metadata
        print(f"\n{'='*80}")
        print("Response Metadata:")
        print(f"{'='*80}")
        print(f"Session ID: {session_id}")
        print(f"Response Length: {len(completion_text)} characters")
        print(f"Status: Success")
        
        return True, completion_text
        
    except client.exceptions.ResourceNotFoundException as e:
        print(f"\n❌ ERROR: Agent not found")
        print(f"Details: {str(e)}")
        return False, None
        
    except client.exceptions.AccessDeniedException as e:
        print(f"\n❌ ERROR: Access denied")
        print(f"Details: {str(e)}")
        print(f"\nCheck IAM permissions for bedrock-agent-runtime:InvokeAgent")
        return False, None
        
    except Exception as e:
        print(f"\n❌ ERROR: {type(e).__name__}")
        print(f"Details: {str(e)}")
        return False, None

def run_test_suite():
    """Run a suite of test queries"""
    
    print("\n" + "="*80)
    print("BEDROCK AGENT TEST SUITE")
    print("="*80)
    
    test_queries = [
        "What is your purpose and what can you help me with?",
        "What types of synthetic data can you generate?",
        "Explain your capabilities for QA testing.",
    ]
    
    results = []
    
    for i, query in enumerate(test_queries, 1):
        print(f"\n\n{'#'*80}")
        print(f"TEST {i} of {len(test_queries)}")
        print(f"{'#'*80}")
        
        success, response = test_agent_invocation(query)
        results.append({
            'query': query,
            'success': success,
            'response_length': len(response) if response else 0
        })
        
        if i < len(test_queries):
            print("\nWaiting before next test...")
            import time
            time.sleep(2)
    
    # Summary
    print(f"\n\n{'='*80}")
    print("TEST SUMMARY")
    print(f"{'='*80}")
    
    for i, result in enumerate(results, 1):
        status = "✅ PASS" if result['success'] else "❌ FAIL"
        print(f"\nTest {i}: {status}")
        print(f"  Query: {result['query'][:60]}...")
        if result['success']:
            print(f"  Response Length: {result['response_length']} characters")
    
    success_count = sum(1 for r in results if r['success'])
    total_count = len(results)
    
    print(f"\n{'='*80}")
    print(f"RESULTS: {success_count}/{total_count} tests passed")
    print(f"{'='*80}\n")
    
    return success_count == total_count

if __name__ == "__main__":
    # Check if custom query provided
    if len(sys.argv) > 1:
        # Single test with custom query
        custom_query = " ".join(sys.argv[1:])
        success, _ = test_agent_invocation(custom_query)
        sys.exit(0 if success else 1)
    else:
        # Run full test suite
        success = run_test_suite()
        sys.exit(0 if success else 1)
