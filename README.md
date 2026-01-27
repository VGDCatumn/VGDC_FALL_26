# VGDC_FALL_26
Upstream is the repository that you forked from. It can be a good idea to add this repo as a remote on your local checkout to make it easier to fetch changes "from upstream" to work with. The name "upstream" is just a convention, and you could easily call it "organization_repo" or "wonderimpornium" or whatever you'd like.

To rebase is to rewrite history. It's one of those polarizing concepts in the git world because it's awesomely powerful and cool. Some folks feel like you shouldn't rebase ever since it has the possibility to fuck up everything. Other folks (like myself) engage in rebasing multiple times a day, sometimes with multiple partners. With great power comes great responsibility, yadda yadda yadda.

Let's say you have a repo like this:

A - B - C

where C is where master is on the remote (hence the bolding) and the local (hence the italics). You do some work locally and make a few commits before pushing the changes upstream (see the vocab callback there?). So your local repo looks like this:

A - B - C - D - E - F

where C is where master is on the remote, and F is where master is locally.

You've been pushing forward progress and making things awesome. Now it's time to share those 3 awesome commits (D, E & F) with the world. The first thing you do is fetch any new work that anyone else has done. But uh oh... that rat-bastard Bob has performed some commits too! So now the state of the repo looks like this:

A - B - C - DBob - EBob - FBob - GBob

            \ D - E - F

What to do, what to do? Bob has done all this work without you, and you need to get caught up before you share your work with the world.

The aforementioned folks who feel like you should never rebase would say that you should perform a merge of Bob's code into your code, and then push. But this results in a merge commit like so:

A - B - C - DBob - EBob - FBob - GBob - H

            \ D - E - F -------------------/

Where H is a new merge commit, joining your history and Bob's history and allowing future work to be done with this common ancestry.

Merge commits aren't inherently bad, and they don't litter up the commit history too much, but there is one thing that grinds my gears about them.

Let's say that both you and Bob were working on the WidgetConfig system of the app, and you happen to both add a new parameter to a method. You've added $price and he has added $discount. Aside from the single line of the method parameter declaration, your work does not intersect (his changes are at the end of the method, and yours are at the end).

Git will see that method parameter declaration as a conflict because it can't be asked/trusted to determine which of you is correct. So, when you attempt to do your merge, git will complain about a conflict and refuse to go further until you act. So you go ahead and make the change, ensuring that both $price and $discount are in the signature and making sure that wherever that method is called it is sorted as well. Then you commit. Your merge goes forward and all seems right in the world.

Except (and this is the gear grinding bit) now you have changes associated with some earlier commit (commit D, where you added that parameter) being changed again in some later commit (this new merge commit created). Looking at that conflict resolution commit doesn't tell you much (and all too many people like to have a commit message along the lines of "merge conflicts" which is oh-so-helpful), so now you have to go digging deeper in order to figure out why $price was added, hopefully eventually finding commit D, with the helpful commit message of "adding $price calculation to appease marketing. See ticket #37"

Compare this with rebasing.

When you see that Bob has made changes, you think "Okay, his changes are in the system, now I need to add my changes too" so you effectively just take your commits (D, E & F) and apply them on top of Bob's changes. What you are technically doing is saying that you want the base of that specific chain of commits (D, E & F), to no longer be C, but instead want the base to be GBob. What you end up with is this:

A - B - C - DBob - EBob - FBob - GBob - D - E - F

Simple, clean, clear and allows for easy reading of the commit history.

But what of that conflict I mentioned earlier? Bob's addition of $discount which caused such problems? That conflict will now be picked up when git is attempting to apply commit D to GBob. Git will see that there is a problem and FreakTheFuckOut™ and not proceed any further. This might seem bad, but it allows for you to change that commit before moving on. Read that again, it's worth it. Git allows you to change a commit you made in the past and keep moving on without majorly messing up your day.

Now that you know that Bob's changes conflict with your changes, you do the same sort of fixes you did before to make everything copacetic and commit the changes. The difference is that now commit D takes into account Bob's changes. Your conflict (and shame) is hidden from history. Nobody needs to know that you had this conflict, because nobody cares. They care that ticket #37 was put in because marketing wanted $price to be calculated. And that is what they will see with your commit message.

A long ass response to only part of your question, but I love me some rebasing action and know that it can be super powerful and awesome. I highly advise setting branch.autosetuprebase always in your .gitconfig and reaping the benefits as soon as possible.



