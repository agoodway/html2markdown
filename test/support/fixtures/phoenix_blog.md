[Phoenix Framework![](/images/phoenix-orange.png)](/)

[Docs](https://hexdocs.pm/phoenix/)

[Community](https://hexdocs.pm/phoenix/community.html)

[Source](https://github.com/phoenixframework/phoenix)

[Blog](/blog)

# Phoenix 1.8.0-rc released!

Posted on March 30th, 2025 by Chris McCord



---



The first release candidate of Phoenix 1.8 is out with some big quality-of-life improvements! We’ve focused on making the getting started experience smoother, tightened up our code generators, and introduced scopes for secure data access that scales with your codebase. On the UX side, we added long-requested dark mode support — plus a few extra perks along the way. And `phx.gen.auth` now ships with magic link support out of the box for a better login and registration experience.

*Note*: This release requires Erlang/OTP 25+.

### Extensible Tailwind Theming and Components with daisyUI

Phoenix 1.8 extends our built-in tailwindcss support with [daisyUI](https://daisyui.com/), adding a flexible component and theming system. As a tailwind veteran, I appreciate how daisyUI is *just tailwind* with components you drop into existing workflows, while also making it simpler to apply consistent styling across your app when desired. And if you’re new or simply want to adjust the overall look and feel, daisyUI’s theming lets you make broad changes with just a few config tweaks. No fiddly markup rewrites required. Check out [daisyUI’s theme generator](https://daisyui.com/theme-generator/) to see what’s possible.


> *Note*: the `phx.gen.*` Generators do not depend on daisyUI, and because it is a tailwind plugin, it is easy to remove and leaves no additional footprints


All `phx.new` apps now ship with light and dark themes out of the box, with a toggle built into the layout. Here’s the landing page and a `phx.gen.live` form:

[Video](/images/blog/darklight.mp4)

Forms, rounding, shadows, typography, and more can all be adjusted with simple config changes to your `app.css`. This is all possible thanks to daisyUI. We also ship with the latest and greatest from the recent tailwind v4 release.

### Magic Link / Passwordless Authentication by default

The `phx.gen.auth` generator now uses magic links by default for login and registration.


> If you’re a password enthusiast, don’t fret — standard email/pass auth remains opt-in via user settings.


Magic links offer a user-friendly and secure alternative to regular passwords. They’ve grown in popularity for good reason:

- No passwords to remember – fewer failed logins or locked accounts
- Faster onboarding, especially from mobile devices

We also include a `require_sudo_mode` plug, which can be used for pages that contain sensitive operations and enforces recent authentication.

Our generators handle all the security details for you, and with the Dev Preview Mailbox, your dev workflow stays hassle free. Thanks to our integration with [Swoosh](https://hex.pm/packages/swoosh), your email-backed auth system is ready to go the moment you’re ready to ship to prod.

Let’s see it in action:

[Video](/images/blog/magicauth.mp4)

### Scopes for data access and authorization patterns that grow with you

Scopes are a new first-class pattern in Phoenix, designed to make secure data access the *default*, not something you remember (or forget) to do later. Reminder that broken access control is [*the most common OWASP vulnerability*](https://owasp.org/Top10/A01_2021-Broken_Access_Control/).

Scopes also help your interfaces grow with your application needs. Think about it as a container that holds information that is required in the huge majority of pages in your app. It can also hold important request metadata, such as IP addresses for rate limiting or audit tracking.

Generators like `phx.gen.live`, `phx.gen.html`, and `phx.gen.json` now use the current scope for generated code. From the original request, the tasks automatically thread the current scope through all the context functions like `list_posts(scope)` or `get_post!(scope, id)`, ensuring your application stays locked down by default. This gives you scoped data access (queries *and* PubSub!), automatic filtering by user or organization, and proper foreign key fields in migrations – all out of the box.

And scopes are *simple*. It’s just a plain struct in your app that your app wholly owns. The moment you run `phx.gen.auth`, you gain a new `%MyApp.Accounts.Scope{}` data structure that centralizes the information for the current request or session — like the current user, their organization, or anything else your app needs to know to securely load and manipulate data, or interact with the system.

Scopes also scale with your codebase. You can define multiple scopes, augment existing ones, such as adding an `:organization` field to your user scope, or even configure how scope values appear in URLs for user-friendly slugs.

Scopes aren’t just a security feature. They provide a foundation for building multi-tenant, team-based, or session-isolated apps, slot cleanly into the router and LiveView lifecycle, and stay useful even outside the context of a request. Think role verification, or programmatic access patterns where you need to know if a call came from the system or an end-user.

Be sure to check out the [full scopes guide](https://hexdocs.pm/phoenix/1.8.0-rc.0/scopes.html) for in depth instructions on using scopes in your own applications, but let’s walk through a quick example from the guide.

#### Integration of scopes in the Phoenix generators

If a default scope is defined in your application’s config, the generators will generate scoped resources by default. The generated LiveViews / Controllers will automatically pass the scope to the context functions. `mix phx.gen.auth` automatically sets its scope as default, if there is not already a default scope defined:

```elixir
# config/config.exs
config :my_app, :scopes,
  user: [
    default: true,
    ...
  ]
```

Let’s look at the code generated once a default scope is set:

```console
$ mix phx.gen.live Blog Post posts title:string body:text
```

This creates a new `Blog` context, with a `Post` resource. To ensure the scope is available, for LiveViews the routes in your `router.ex` must be added to a `live_session` that ensures the user is authenticated:

```diff
   scope "/", MyAppWeb do
     pipe_through [:browser, :require_authenticated_user]

     live_session :require_authenticated_user,
       on_mount: [{MyAppWeb.UserAuth, :ensure_authenticated}] do
       live "/users/settings", UserLive.Settings, :edit
       live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email

+      live "/posts", PostLive.Index, :index
+      live "/posts/new", PostLive.Form, :new
+      live "/posts/:id", PostLive.Show, :show
+      live "/posts/:id/edit", PostLive.Form, :edit
     end

     post "/users/update-password", UserSessionController, :update_password
   end
```

Now, let’s look at the generated LiveView ( `lib/my_app_web/live/post_live/index.ex`):

```elixir
defmodule MyAppWeb.PostLive.Index do
  use MyAppWeb, :live_view

  alias MyApp.Blog

  ...

  @impl true
  def mount(_params, _session, socket) do
    Blog.subscribe_posts(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "Listing Posts")
     |> stream(:posts, Blog.list_posts(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Blog.get_post!(socket.assigns.current_scope, id)
    {:ok, _} = Blog.delete_post(socket.assigns.current_scope, post)

    {:noreply, stream_delete(socket, :posts, post)}
  end

  @impl true
  def handle_info({type, %MyApp.Blog.Post{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :posts, Blog.list_posts(socket.assigns.current_scope), reset: true)}
  end
end
```

Note that every function from the `Blog` context that we call gets the `current_scope` assign passed in as the first argument. The `list_posts/1` function then uses that information to properly filter posts:

```elixir
# lib/my_app/blog.ex
def list_posts(%Scope{} = scope) do
  Repo.all(from post in Post, where: post.user_id == ^scope.user.id)
end
```

The LiveView even subscribes to scoped PubSub messages and automatically updates the rendered list whenever a new post is created or an existing post is updated or deleted, while ensuring that only messages for the current scope are processed.

### Streamlined Onboarding

Phoenix v1.7 introduced a unified developer experience for building both old-fashioned HTML apps and realtime interactive apps with LiveView. This made LiveView and HEEx function components front and center as the new building blocks for modern Phoenix applications.

As part of this effort, we introduced a `core_components.ex` file that provides declarative components to use throughout your app. Those components were the back-bone of the `phx.gen.html` code generator as well as the new `phx.gen.live` task. Phoenix developers would then evolve those components over time, as needed by their applications.

While these additions were useful to showcase what you can achieve with Phoenix LiveView, they would often get in the way of experienced developers, by generating too much opinionated code. At the same time, they could also overwhelm someone who was just starting with Phoenix.

Now, after receiving feedback from new and senior developers alike, and with Phoenix LiveView 1.0 officially out, we chose to simplify several of our code generators. Our goal is to give seasoned folks a better foundation to build the real features they want to ship, while giving newcomers simplified code which will help them get up to speed on the basics more quickly:

The `mix phx.gen.live` generator now follows its sibling, `mix phx.gen.html`, to provide a straight-forward CRUD interface you can build on top of, while showcasing the main LiveView concepts. In turn, this allows us to trim down the core components to only the main building blocks.

Even the `mix phx.gen.auth` generator, which received the magic link support and sudo mode mentioned above, does so in fewer files, fewer functions, and fewer lines of code.

The [context guide](https://hexdocs.pm/phoenix/1.8.0-rc.0/contexts.html) has been broken apart into a few separate guides that now better explores data modeling, using ecommerce to drive the examples.

We also have new guides for authentication and authorization, which combined with scopes, gives you a solid starting point to designing secure and maintainable projects.

### Simplified Layouts

We have also revised Phoenix nested layouts, `root.html.heex` and `app.html.heex`, in favor of a single layout that is then augmented with function components.

Previously, `root.html.heex` was the static layout and `app.html.heex` was the dynamic one that can be updated throughout the lifecycle of your LiveViews. This remains the case, but the app layout usage in 1.8 has been simplified.

Our prior approach set apps up with a fixed app layout via `use Phoenix.LiveView, layout: ...` options, which could be confusing and also required too much ceremony to support multiple app layouts programmatically. Instead, root layout remains unchanged, while the app layout has been made an explicit function component call wherever you want to include a dynamic app layout.

Here is an example of how we could augment the new app layout in Phoenix with breadcrumbs and then easily reuse them across pages.

First, we’d add an optional `:breadcrumb` slot to our `<Layouts.app>` function component, which renders the breadcrumbs above the caller’s inner block:

```elixir
defmodule AppWeb.Layouts do
  use AppWeb, :html

  embed_templates "layouts/*"

  slot :breadcrumb, required: false

  def app(assigns)
    ~H"""
    ...
    <main class="px-4 py-20 sm:px-6 lg:px-8">
      <div :if={@breadcrumb != []} class="py-4 breadcrumbs text-sm">
        <ul>
          <li :for={item <- @breadcrumb}>{render_slot(item)}</li>
        </ul>
      </div>
      <div class="mx-auto max-w-2xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>
    """
  end
end
```

Then in any of our LiveViews that want breadcrumbs, the caller can declare them:

```elixir
@impl true
def render(assigns) do
  ~H"""
  <Layouts.app flash={@flash}>
    <:breadcrumb>
      <.link navigate={~p"/posts"}>All Posts</.link>
    </:breadcrumb>
    <:breadcrumb>
      <.link navigate={~p"/posts/#{@post}"}>View Post</.link>
    </:breadcrumb>
    <.header>
      Post {@post.id}      <:subtitle>This is a post record from your database.</:subtitle>
      <:actions>
        <.link class="btn" navigate={~p"/posts/#{@post}/edit"}>Edit post</.link>
      </:actions>
    </.header>
    <p>
      My LiveView Page
    </p>
  </Layouts.app>
  """
end
```

And this is what it looks like in action:

[Video](/images/blog/breadcrumbs.mp4)

Notice how the app layout is now an explicit call. If you have other app layouts, like a cart page, admin page, etc, you simply write a new `<Layouts.admin flash={@flash}>`, passing whatever assigns you need.

Supporting something like this with our prior app layout approach would have required feeding assigns to the app layout and branching based on some conditions, and mucking with `app_web.ex` to support additional layout options. Now, the caller is simply free to handle their layout concerns inline.

Combined with daisyUI component classes, the streamlined layouts and onboarding experience offers a fantastic starting point for rapid development, with easy customization and a robust component system to choose from.

### Try it out

You can update existing `phx.new` installations with:

```shell
mix archive.install hex phx_new 1.8.0-rc.0 --force
```

Reminder, we launched `new.phoenixframework.org` several months ago which lets you get up and running in seconds with Elixir and your first Phoenix project with a single command.

You can use it to take Phoenix v1.8 release candidate for a spin:

For osx/linux:

```bash
$ curl https://new.phoenixframework.org/myapp | sh
```

For Windows PowerShell:

```cmd
> curl.exe -fsSO https://new.phoenixframework.org/app.bat; .\app.bat
```

Phoenix 1.8 brings improvements to developer productivity and app structure, from scoped data access that grows with your domain to tailwind theming that grows with your design. Combined with passwordless auth and lighter generators this release should streamline your app development whether you’re a new user or building along with us for the last 10 years.

Huge shoutout to [Steffen Deusch](https://github.com/steffenDE) and his [Dashbit](https://dashbit.co/) sponsored work for making the majority of the features here happen!

*Note*: This is a backwards compatible release with [a few deprecations](https://github.com/phoenixframework/phoenix/blob/b1c459943b3279f97725787b9150ff4950958d12/CHANGELOG.md).

As always, find us on elixirforum, slack, or discord if you have questions or need help.

Happy coding!

–Chris

#### Search

#### Follow us

[RSS **](/feed)

[GitHub](https://github.com/phoenixframework)

#### Tags

- [CI](/blog/tags/CI)
- [ML](/blog/tags/ML)
- [bumbleebee](/blog/tags/bumbleebee)
- [channels](/blog/tags/channels)
- [elixirconf](/blog/tags/elixirconf)
- [generators](/blog/tags/generators)
- [guides](/blog/tags/guides)
- [liveview](/blog/tags/liveview)
- [nx](/blog/tags/nx)
- [phoenix](/blog/tags/phoenix)
- [pubsub](/blog/tags/pubsub)
- [releases](/blog/tags/releases)
- [testing](/blog/tags/testing)
- [uploads](/blog/tags/uploads)

#### Recent Posts

- [Phoenix 1.8.0-rc released!](/blog/phoenix-1-8-released)
- [Phoenix LiveView 1.0.0 is here!](/blog/phoenix-liveview-1.0-released)
- [Phoenix LiveView 0.19 released](/blog/phoenix-liveview-0.19-released)
-   
[See all](/blog)

© 2024 phoenixframework.org
|

[@elixirphoenix](https://twitter.com/elixirphoenix)

  


DockYard offers expert

[Phoenix consulting](https://dockyard.com/capabilities/elixir-consulting)

for your projects