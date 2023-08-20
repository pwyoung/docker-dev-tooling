#!/usr/bin/env python3


#import json
import os
import sys

import boto3

# Debug BOTO3 REST Call
#
boto3.set_stream_logger(name='botocore')
# 2023-08-15 19:24:45,420 botocore.endpoint [DEBUG] Sending http request: <AWSPreparedRequest stream_output=True, method=POST, url=https://bedrock.us-east-1.amazonaws.com/model/ai21.j2-ultra/invoke, headers={'Accept': b'application/json', 'Content-Type': b'application/json', 'User-Agent': b'Boto3/1.28.21 md/Botocore#1.31.21 ua/2.0 os/macos#22.6.0 md/arch#x86_64 lang/python#3.10.12 md/pyimpl#CPython cfg/retry-mode#standard Botocore/1.31.21', 'X-Amz-Date': b'20230815T232445Z', 'Authorization': b'AWS4-HMAC-SHA256 Credential=AKIAREHZADJUT2SOZ3AX/20230815/us-east-1/bedrock/aws4_request, SignedHeaders=accept;content-type;host;x-amz-date, Signature=78b12c5bd3f529606280ef49e2c5d82ac4e0e33fdd37ebb94726f8740eeb1bd7', 'amz-sdk-invocation-id': b'f1aa9f22-1762-4268-9230-60afe86a2691', 'amz-sdk-request': b'attempt=1', 'Content-Length': '161'}>

module_path = ".."
sys.path.append(os.path.abspath(module_path))
from utils import bedrock, print_ww

# Added
import json

class BedrockTest:
    def __init__(self):
        os.environ["AWS_DEFAULT_REGION"] = "us-east-1"

        # TODO: Let them know their doc need to rename this param
        #os.environ["AWS_PROFILE"] = "bedrock"  # Fails if we set this
        os.environ["AWS_PROFILE_NAME"] = "bedrock"

        print("The endpoint is: " + str(os.environ.get("BEDROCK_ASSUME_ROLE", None)))
        print("Showing all ENV vars")
        for name, value in os.environ.items():
            print("{0}: {1}".format(name, value))

        self.boto3_bedrock = bedrock.get_bedrock_client(
            assumed_role=os.environ.get("BEDROCK_ASSUME_ROLE", None),
            endpoint_url=os.environ.get("BEDROCK_ENDPOINT_URL", None),
            region=os.environ.get("AWS_DEFAULT_REGION", None),
        )

    def show_models(self):
        # https://github.com/aws-samples/amazon-bedrock-workshop/blob/cdf2d6538850800e8363163a6d330e54e8b9c604/00_Intro/bedrock_boto3_setup.ipynb
        # boto3_bedrock.list_foundation_models()

        jd = json.dumps(self.boto3_bedrock.list_foundation_models())
        print( jd )

    """
    Call a Model
    See https://github.com/aws-samples/amazon-bedrock-workshop/blob/main/03_QuestionAnswering/00_qa_w_bedrock_titan.ipynb
    """
    def invoke_titan_model(self, prompt_data, parameters):
        body = json.dumps({"inputText": prompt_data, "textGenerationConfig": parameters})
        modelId = "amazon.titan-tg1-large"  # change this to use a different version from the model provider
        accept = "application/json"
        contentType = "application/json"

        response = self.boto3_bedrock.invoke_model(
            body=body, modelId=modelId, accept=accept, contentType=contentType
        )
        response_body = json.loads(response.get("body").read())
        answer = response_body.get("results")[0].get("outputText")
        print_ww(answer.strip())

    def test_titan_model(self):
        prompt_data = """You are an helpful assistant. Answer questions in a concise way. If you are unsure about the
        answer say 'I am unsure'

        Question: How can I fix a flat tire on my Audi A8?
        Answer:"""

        parameters = {
            "maxTokenCount": 512,
            "stopSequences": [],
            "temperature": 0,
            "topP": 0.9
        }

        self.invoke_titan_model(prompt_data, parameters)



    def invoke_ai21_model(self, all_params):
        json_body = json.dumps(all_params)
        # modelId = "ai21.j2-grande-instruct" # Still works, as of 20230815
        modelId = "ai21.j2-ultra"
        accept = "application/json" # recommended
        # accept = "*/*" # Works, but not in example
        contentType = "application/json"

        response = self.boto3_bedrock.invoke_model(
            body=json_body, modelId=modelId, accept=accept, contentType=contentType
        )
        response_body = json.loads(response.get("body").read())
        answer = response_body.get("completions")[0].get("data").get("text")
        print_ww(answer.strip())

    def test_ai21_model(self):
        prompt_data = """
        Question: How can I fix a flat tire on my Audi A8?
        Answer:"""

        # The penalty fields seem to be optional
        # Boto3 doesn't send them if they are unspecified
        params_WORKING = {
            "prompt": prompt_data,
            "maxTokens": 200,
            "temperature": 0.5,
            "topP": 0.5,
            "stopSequences": [],
            "countPenalty": {"scale": 0},
            "presencePenalty": {"scale": 0},
            "frequencyPenalty": {"scale": 0}
        }

        params = {
            "prompt": prompt_data,
            "maxTokens": 200,
            "temperature": 0,
            "topP": 0.9,
            "stopSequences": [],
        }

        self.invoke_ai21_model(params)


t = BedrockTest()
t.show_models()
t.test_titan_model()
t.test_ai21_model()

