import base64
import vertexai
from vertexai.preview.generative_models import GenerativeModel


def generate():
    model = GenerativeModel("gemini-pro-vision")
    responses = model.generate_content(
        ["""Tell me about the University of Colorad, Anschutz Medical Campus."""],
        generation_config={
            "max_output_tokens": 2048,
            "temperature": 0.4,
            "top_p": 1,
            "top_k": 32,
        },
    )

    print(responses)


def main():
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("--json_key_file", type=str)
    args = parser.parse_args()

    if args.json_key_file is not None:
        import os

        print(f"Setting GOOGLE_APPLICATION_CREDENTIALS to {args.json_key_file}")
        os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = args.json_key_file
    generate()


if __name__ == "__main__":
    main()
