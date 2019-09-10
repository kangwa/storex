defmodule Storex.Server do
  use GenServer
  @name :storex

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: :storex])
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def write(key, value) do
    GenServer.call(@name, {:write, {key, value}})
  end

  def read(key) do
    GenServer.call(@name, {:read, key})
  end

  def delete(key) do
    GenServer.cast(@name, {:delete, key})
  end

  def clear() do
    GenServer.cast(@name, :clear)
  end

  def exist?(key) do
    GenServer.call(@name, {:exist, key})
  end


  ## Server Callbacks

  def handle_call({:write, {key, value}}, _from, cache) do
    cache = Map.put(cache, key, value)
    {:reply, cache, cache}
  end

  def handle_call({:read, key}, _from, cache) do
    result = Map.fetch(cache, key)
    {:reply, result, cache}
  end

  def handle_call({:exist, key}, _from, cache) do
    {:reply, Map.has_key?(cache, key), cache}
  end

  def handle_cast({:delete, key}, _from, cache) do
    updated_cache = Map.delete(cache, key)
    {:noreply, updated_cache}
  end

  def handle_cast(:clear, _cache) do
    {:noreply, %{}}
  end
end
