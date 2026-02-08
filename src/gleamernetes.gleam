import envoy
import gleam/list

import gleam/dict
import gleam/io
import yay

fn get_all_contexts(
  node: yay.Node,
) -> Result(List(dict.Dict(String, String)), yay.ExtractionError) {
  yay.extract_list_with(node, "contexts", fn(item) {
    let assert Ok(context_dict) = yay.extract_string_map(item, "context")
    let assert Ok(name) = yay.extract_string(item, "name")
    let context =
      context_dict
      |> dict.to_list
      |> dict.from_list
      |> dict.merge(dict.from_list([#("name", name)]))

    Ok(context)
  })
}

fn get_all_users(
  node: yay.Node,
) -> Result(List(dict.Dict(String, String)), yay.ExtractionError) {
  yay.extract_list_with(node, "users", fn(item) {
    let assert Ok(context_dict) = yay.extract_string_map(item, "user")
    let assert Ok(name) = yay.extract_string(item, "name")
    let user =
      context_dict
      |> dict.to_list
      |> dict.from_list
      |> dict.merge(dict.from_list([#("name", name)]))

    Ok(user)
  })
}

fn get_all_clusters(
  node: yay.Node,
) -> Result(List(dict.Dict(String, String)), yay.ExtractionError) {
  yay.extract_list_with(node, "clusters", fn(item) {
    let assert Ok(context_dict) = yay.extract_string_map(item, "cluster")
    let assert Ok(name) = yay.extract_string(item, "name")
    let cluster =
      context_dict
      |> dict.to_list
      |> dict.from_list
      |> dict.merge(dict.from_list([#("name", name)]))

    Ok(cluster)
  })
}

fn get_user_detail(
  node: yay.Node,
  user_name: String,
) -> dict.Dict(String, String) {
  let assert Ok(users) = get_all_users(node)
  let assert Ok(user_detail) =
    list.filter(users, fn(user) { dict.get(user, "name") == Ok(user_name) })
    |> list.first
  user_detail
}

fn get_cluster_detail(
  node: yay.Node,
  cluster_name: String,
) -> dict.Dict(String, String) {
  let assert Ok(clusters) = get_all_clusters(node)
  let assert Ok(cluster_detail) =
    list.filter(clusters, fn(cluster) {
      dict.get(cluster, "name") == Ok(cluster_name)
    })
    |> list.first
  cluster_detail
}

fn get_context_detail(
  node: yay.Node,
  context_name: String,
) -> dict.Dict(String, String) {
  let assert Ok(contexts) = get_all_contexts(node)
  let assert Ok(context_detail) =
    list.filter(contexts, fn(context) {
      dict.get(context, "name") == Ok(context_name)
    })
    |> list.first
  context_detail
}

pub fn main() -> Nil {
  // let root = yaml_to_root("servers: [{name: first}, {name: second}]")
  // let assert Ok(pwd) = envoy.get("PWD")
  // let assert Ok([doc]) = yay.parse_file(pwd <> "/kubeconfig")
  let assert Ok(home) = envoy.get("HOME")
  let assert Ok([doc]) = yay.parse_file(home <> "/.kube/config")
  let root = yay.document_root(doc)

  // Get the current context detail as Dict(String, String)
  let assert Ok(current_context) = yay.extract_string(root, "current-context")
  let current_context_detail = get_context_detail(root, current_context)

  // Get the currect user details as Dict(String, String)
  let assert Ok(user) = dict.get(current_context_detail, "user")
  let current_user_detail = get_user_detail(root, user)

  // Get the currect cluster detail as Dict(String, String)
  let assert Ok(cluster) = dict.get(current_context_detail, "cluster")
  let current_cluster_detail = get_cluster_detail(root, cluster)

  echo current_context_detail
  echo current_user_detail
  echo current_cluster_detail
  io.println(current_context)
  io.println("Hello from gleamernetes!")
}
