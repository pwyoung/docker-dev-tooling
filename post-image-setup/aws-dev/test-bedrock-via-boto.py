#!/usr/bin/env python3

import json
import os
import sys
import boto3

# https://docs.aws.amazon.com/bedrock/latest/userguide/api-methods-run-inference.html
# https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-meta.html#model-parameters-llama-request-body

class BedrockTest:
    def __init__(self):
        os.environ["AWS_DEFAULT_REGION"] = "us-west-2"
            
        self.bedrock_runtime = boto3.client(service_name='bedrock-runtime')
        self.bedrock = boto3.client(service_name='bedrock')
        
    def show_models(self):
        jd = json.dumps(self.bedrock.list_foundation_models())
        print( jd )

        
    def test_llama_model_with_streaming(self, prompt_data):       
        modelId = "meta.llama2-13b-chat-v1"
        accept = "*/*"
        contentType = "application/json"

        # https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-meta.html#model-parameters-llama-request-body        
        body = json.dumps(
            {
                "prompt": prompt_data,
                "max_gen_len": 512,
                "temperature": 0.2,
                "top_p": 0.9
            }
        )

        try:
            response = self.bedrock_runtime.invoke_model_with_response_stream(
                body=body,
                modelId=modelId,
                accept=accept,
                contentType=contentType
            )
        except Exception as e:
            et=str(type(e))
            if "ResourceNotFoundException" in et:
                print("Likely cause: 3rd-party models require explicit access be granted !")
                print("See https://docs.aws.amazon.com/bedrock/latest/userguide/foundation-models.html#foundation-models-access")
                print(e)
            elif "AccessDeniedException" in et:
                print("Likely cause: Foundation models require explicit access be granted !")
                print("See https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html#add-model-access")
                print(e)
            else:
                print(f"Unkown Exception. Type={et} Exception={e}")
    
        stream = response.get('body')
        if stream:
            for event in stream:
                chunk = event.get('chunk')
                if chunk:
                    print(json.loads(chunk.get('bytes').decode()))

    def test_llama_model_without_streaming(self, prompt_data):
        modelId = "meta.llama2-13b-chat-v1"
        accept = "*/*"
        contentType = "application/json"    

        body = json.dumps(
            {
                "prompt": prompt_data,
                "max_gen_len": 512,
                "temperature": 0.2,
                "top_p": 0.9
            }
        )

        try:
            response = self.bedrock_runtime.invoke_model(
                body=body,
                modelId=modelId,
                accept=accept,
                contentType=contentType
            )                                                                                                                                                        
        except Exception as e:
            et=str(type(e))
            if "ResourceNotFoundException" in et:
                print("Likely cause: 3rd-party models require explicit access be granted !")
                print("See https://docs.aws.amazon.com/bedrock/latest/userguide/foundation-models.html#foundation-models-access")
                print(e)
            elif "AccessDeniedException" in et:
                print("Likely cause: Foundation models require explicit access be granted !")
                print("See https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html#add-model-access")
                print(e)
            else:
                print(f"Unkown Exception. Type={et} Exception={e}")

        response_body = json.loads(response.get('body').read())
        print(response_body.get('generation'))

                    
t = BedrockTest()
t.show_models()

# Works, as of 11/16/23, after granting access
prompt_data="Explain a black-hole to a 5 year old"
#t.test_llama_model_with_streaming(prompt_data)
t.test_llama_model_without_streaming(prompt_data)

