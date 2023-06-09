
Use the `commit` command to add, commit and push all at once, with the commit message made by ChatGPT.

Demo: All of the [commit messages](https://github.com/stevecondylios/gpt-generated-commit-messages/commits/main) for this project were generated by ChatGPT (except the first one). It works on any repo and setup is as quick as adding the function below to your bashrc or equivalent. 

This obviously shouldn't be used for serious projects, but it's a fun way to play around with CHATGPT's models and save a little time on projects where you commit messages don't matter much.


<img src="docs/imgs/commit.gif">

# Setup 

Add the following code to `~/.bashrc`, or `~/.zshrc`, and open a new terminal window (or just copy/paste it all into a new terminal session and set the `OPENAI_API_KEY` environment variable in the same session):

```bash
git_diff_and_new_files() {
    echo "Git diff:"
    git diff "$@"
    
    new_files=$(git ls-files --others --exclude-standard)
    
    if [[ -n "$new_files" ]]; then
        echo -e "\nNew files:"
        echo "$new_files"
    fi
}

commit() {
  OPENAI_API_KEY=$OPENAI_API_KEY # Store key in ~/.zshenv e.g. export OPENAI_API_KEY="sk-YZlDA7sk2hbv6G6F8jg0sdfsdfsdf" or can be added here directly. 
  GIT_DIFF_OUTPUT=$(git_diff_and_new_files)
  ENCODED_DIFF_OUTPUT=$(printf "%s" "${GIT_DIFF_OUTPUT}" | jq -sRr @uri)

  GPT_RESPONSE=$(curl https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d "{
    \"model\": \"gpt-3.5-turbo\",
    \"messages\": [{\"role\": \"user\", \"content\": \"Can you give a short commit message (under 50 words) that summarises the changes represented by this \`git diff\` output: $ENCODED_DIFF_OUTPUT\"}],
    \"temperature\": 0.7
  }")

  COMMIT_MESSAGE=$(echo -E -n $GPT_RESPONSE | jq -r ".choices[0].message.content")

  if [ -n "${COMMIT_MESSAGE}" ]; then
    git add --all
    git commit -m "${COMMIT_MESSAGE}"
    git push
  else
    echo "Error: Couldn't generate a commit message."
  fi
}
```

and grab an [OpenAI API key](https://help.openai.com/en/articles/4936850-where-do-i-find-my-secret-api-key) and add it to `.zshenv` (or hard code it in the function above):

```
export OPENAI_API_KEY="sk-YZlDA7sk2hbv6G6F8jg0sdfsdfsdf"
```

and you're ready to go!

# Usage

`cd` into any git repo, make some changes, and run `commit`. That one command will do the equivalent of

```bash
git add . 
git commit -m <GPT generated message>
git push
```

**A note on cost**

The GPT 3.5 turbo engine is 1/5th of a cent per 1000 tokens. Ref: https://openai.com/blog/introducing-chatgpt-and-whisper-apis

A single commit can take up to about 4000 tokens. 


# Pull requests

This was a fun play around with ChatGPT's models, if you have suggestions/improvements, please make them via a [GitHub Issue]() or fork this repo and make a pull request.




